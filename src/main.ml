(* This file is part of the Catala compiler, a specification language for tax
   and social benefits computation rules. Copyright (C) 2025 Inria, contributor:
   Vincent Botbol <vincent.botbol@inria.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not
   use this file except in compliance with the License. You may obtain a copy of
   the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
   License for the specific language governing permissions and limitations under
   the License. *)

type files = {
  config_file : string;
  query_file : string;
  topiary_path : string;
}

let process_out cmd args =
  let finally f k =
    match k () with
    | exception e ->
        f () ;
        raise e
    | r ->
        f () ;
        r
  in
  let aargs = Array.of_list (cmd :: args) in
  let ic =
    try Unix.open_process_args_in cmd aargs
    with Unix.Unix_error (Unix.ENOENT, _, _) ->
      Printf.ksprintf failwith "ERROR: program %s not found" cmd
  in
  let buf = Buffer.create 4096 in
  finally
    (fun () -> Unix.close_process_in ic |> ignore)
    (fun () ->
      try
        while true do
          Buffer.add_channel buf ic 4096
        done ;
        assert false
      with End_of_file -> Buffer.contents buf)

let ( / ) = Filename.concat

let check_and_build ~query_file ~config_file ~topiary_path =
  let topiary_path =
    if Sys.file_exists topiary_path then topiary_path else topiary_path ^ ".exe"
  in
  List.for_all Sys.file_exists [ query_file; config_file; topiary_path ]
  |> function
  | true -> Some { query_file; config_file; topiary_path }
  | false -> None

let lookup_windows () =
  try
    let ( let*? ) b f = if not b then None else f () in
    let*? () = Sys.win32 in
    let*? () = Sys.getenv_opt "LOCALAPPDATA" <> None in
    let appdata_dir = Sys.getenv "LOCALAPPDATA" in
    let catala_install_dir = appdata_dir / "Catala" in
    let query_file = catala_install_dir / "catala.scm" in
    let config_file = catala_install_dir / "catala.ncl" in
    let topiary_path = catala_install_dir / "topiary" in
    check_and_build ~query_file ~config_file ~topiary_path
  with _ -> None

let exec_dir =
  lazy
    (let cmd = Sys.argv.(0) in
     if String.contains cmd '/' then
       (* Do not use Sys.executable_name, which may resolve symlinks: we want the
          original path. (e.g. _build/install/default/bin/foo is a symlink) *)
       Filename.dirname cmd
     else (* searched in PATH *)
       Filename.dirname Sys.executable_name)

let lookup_opam_optimist () =
  (* Querying opam is slow, let's hypothesize that the binary is in
     opam's bin dir. e.g. <OPAM>/<SWITCH>/bin *)
  try
    let exec_dir = Lazy.force exec_dir in
    let topiary_share_dir =
      exec_dir / Filename.parent_dir_name / "share" / "topiary"
    in
    let query_file = topiary_share_dir / "queries" / "catala.scm" in
    let config_file = topiary_share_dir / "configs" / "catala.ncl" in
    let topiary_path = exec_dir / ".topiary-wrapped" / "topiary" in
    check_and_build ~query_file ~config_file ~topiary_path
  with _ -> None

let lookup_opam_slow () =
  try
    let topiary_share_dir =
      String.trim (process_out "opam" [ "var"; "topiary:share" ])
    in
    let topiary_bin_dir = String.trim (process_out "opam" [ "var"; "bin" ]) in
    let query_file = topiary_share_dir / "queries" / "catala.scm" in
    let config_file = topiary_share_dir / "configs" / "catala.ncl" in
    let topiary_path = topiary_bin_dir / ".topiary-wrapped" / "topiary" in
    check_and_build ~query_file ~config_file ~topiary_path
  with _ -> None

let lookup_exec_dir () =
  try
    let exec_dir = Lazy.force exec_dir in
    let query_file = exec_dir / "catala.scm" in
    let config_file = exec_dir / "catala.ncl" in
    let topiary_path = exec_dir / "topiary" in
    check_and_build ~query_file ~config_file ~topiary_path
  with _ -> None

let files_lookup () =
  let ( let* ) x f = match x with Some x -> x | None -> f () in
  let* () = lookup_windows () in
  let* () = lookup_opam_optimist () in
  let* () = lookup_exec_dir () in
  let* () = lookup_opam_slow () in
  Format.eprintf "Error: unable to locate catala-format's config files@." ;
  Stdlib.exit Cmdliner.Cmd.Exit.internal_error

let supported_languages = [ "catala_en"; "catala_fr"; "catala_pl" ]

let error s =
  Format.pp_print_string Format.err_formatter s ;
  Stdlib.exit 2

let buf_len = 4096

let glob_buf = Bytes.create (buf_len * 2)

let remove_carriage_returns (buf, buf_len) =
  let buf'_len = ref 0 in
  for i = 0 to buf_len - 1 do
    match Bytes.get buf i with
    | '\r' -> ()
    | c ->
        Bytes.set glob_buf !buf'_len c ;
        incr buf'_len
  done ;
  (glob_buf, !buf'_len)

let map_in_file ~f (fd_in : Unix.file_descr) =
  let buff = Bytes.create buf_len in
  let (fd_out, fd_in') = Unix.pipe ~cloexec:true () in
  let rec loop () =
    match Unix.read fd_in buff 0 buf_len with
    | 0 -> Unix.close fd_in'
    | n ->
        let (buff', n') = f (buff, n) in
        ignore @@ Unix.write fd_in' buff' 0 n' ;
        if n = buf_len then loop () else Unix.close fd_in'
  in
  try
    loop () ;
    fd_out
  with _ -> fd_out

let add_carriage_returns (buf, buf_len) =
  let buf'_len = ref 0 in
  for i = 0 to buf_len - 1 do
    (match Bytes.get buf i with
    | '\n' as c ->
        Bytes.set glob_buf !buf'_len '\r' ;
        incr buf'_len ;
        c
    | c -> c)
    |> fun c ->
    Bytes.set glob_buf !buf'_len c ;
    incr buf'_len
  done ;
  (glob_buf, !buf'_len)

let write_result ~has_cr ~fd_out ~fd_in =
  let buf = Bytes.create buf_len in
  let rec loop () =
    match Unix.read fd_in buf 0 buf_len with
    | 0 -> Unix.close fd_in
    | n ->
        let (buf', buf'_len) =
          if has_cr then add_carriage_returns (buf, n) else (buf, n)
        in
        let _ = Unix.write fd_out buf' 0 buf'_len in
        if n = buf_len then loop () else Unix.close fd_in
  in
  loop ()

let contains_carriage_returns fd =
  let l = Stdlib.input_line (Unix.in_channel_of_descr fd) in
  ignore @@ Unix.lseek fd 0 SEEK_SET ;
  l.[String.length l - 1] = '\r'

let format_cmd =
  let open Cmdliner in
  let language =
    let open Arg in
    value
    & opt (some (enum (List.map (fun x -> (x, x)) supported_languages))) None
    & info
        [ "l"; "language" ]
        ~docv:"LANG"
        ~doc:
          "Locale variant of the input language to use when it cannot be \
           inferred from the file extension (e.g., when the standard input is \
           read)."
  in
  let in_place =
    let open Arg in
    value & flag
    & info
        [ "i"; "in-place" ]
        ~doc:
          "When specified, the given input file will be overwritten with the \
           formatted content."
  in
  let file =
    let open Arg in
    let converter =
      conv
        ~docv:"FILE"
        ( (fun s ->
            if s = "-" then Ok `Stdin
            else Result.map (fun f -> `File f) (conv_parser non_dir_file s)),
          fun ppf -> function
            | `Stdin -> Format.pp_print_string ppf "-"
            | `File f -> conv_printer non_dir_file ppf f
            | _ -> assert false )
    in
    value & pos 0 converter `Stdin
    & Arg.info
        []
        ~docv:"FILE"
        ~docs:Manpage.s_arguments
        ~doc:"Catala file to be formatted ($(b,-) for stdin)."
  in
  let { config_file; query_file; topiary_path } = files_lookup () in
  let f lang in_place file =
    let language =
      match (lang, file) with
      | (None, `Stdin) ->
          error
            "No file was provided and the Catala's input language was not \
             defined."
      | (None, `File f) -> (
          let ext = Filename.extension f in
          let ext = String.sub ext 1 (String.length ext - 1) in
          List.find_opt (( = ) ext) supported_languages |> function
          | None -> error "Cannot infer Catala's input language"
          | Some l -> l)
      | (Some l, _) -> l
    in
    let args =
      [|
        "topiary";
        "--configuration";
        config_file;
        "format";
        "--language";
        language;
        "--query";
        query_file;
      |]
    in
    let fd =
      match file with
      | `Stdin -> Unix.stdin
      | `File f ->
          let fd = Unix.openfile f [ O_RDONLY; O_CLOEXEC ] 0o444 in
          at_exit (fun () -> Unix.close fd) ;
          fd
    in
    let has_cr = contains_carriage_returns fd in
    let in_fd =
      if has_cr then map_in_file ~f:remove_carriage_returns fd else fd
    in
    let (fd_in, fd_out) =
      let (fd_out, fd_in) = Unix.pipe ~cloexec:true () in
      (fd_in, fd_out)
    in
    let pid = Unix.create_process topiary_path args in_fd fd_in Unix.stderr in
    if pid <> 0 then
      let (_p, status) = Unix.waitpid [ WNOHANG ] pid in
      match status with
      | Unix.WEXITED 0 ->
          let out_file =
            match (file, in_place) with
            | (`Stdin, _) | (_, false) -> Unix.stdout
            | (`File f, true) ->
                let fd =
                  Unix.openfile
                    f
                    [ O_WRONLY; O_TRUNC; O_CLOEXEC ]
                    (Unix.stat f).st_perm
                in
                at_exit (fun () -> Unix.close fd) ;
                fd
          in
          write_result ~has_cr ~fd_out:out_file ~fd_in:fd_out ;
          Stdlib.exit 0
      | WEXITED n | WSIGNALED n | WSTOPPED n -> Stdlib.exit n
  in
  Cmd.v
    (Cmd.info
       "catala-format"
       ~doc:
         "Format the given $(b,FILE) and output the result.\n\
          When no $(b,FILE) is provided, the standard input will be read\n\
          however the $(b,--language) argument becomes mandatory. ")
    Term.(const f $ language $ in_place $ file)

let () =
  let open Cmdliner in
  match Cmd.eval ~catch:false ~argv:Sys.argv format_cmd with
  | 0 -> exit Cmd.Exit.ok
  | n -> exit n
  | exception e ->
      Format.eprintf "Unexpected error: %s@." (Printexc.to_string e) ;
      exit Cmd.Exit.some_error
