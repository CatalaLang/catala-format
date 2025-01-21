let vars = []

let find_and_check ?(allow_none = false) var =
  List.assoc_opt var vars |> function
  | Some None when allow_none -> None
  | Some (Some _ as x) -> x
  | _ -> Format.ksprintf failwith "failed to lookup variable '%s'" var

let query_file_path : string = find_and_check "query_file" |> Option.get

let config_file_path : string = find_and_check "config_file" |> Option.get

let topiary_path : string =
  (* If the value is not present, we look it up in the path through
     [create_process] *)
  find_and_check ~allow_none:true "topiary" |> Option.value ~default:"topiary"

let supported_languages = [ "catala_en"; "catala_fr"; "catala_pl" ]

let error s =
  Format.eprintf "%s@." s ;
  Stdlib.exit 2

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
           read). "
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
  let f lang file =
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
        config_file_path;
        "format";
        "--language";
        language;
        "--query";
        query_file_path;
      |]
    in
    let pid =
      Unix.create_process
        topiary_path
        args
        (match file with
        | `Stdin -> Unix.stdin
        | `File f ->
            let fd = Unix.openfile f [ O_RDONLY ] 0o444 in
            at_exit (fun () -> Unix.close fd) ;
            fd)
        Unix.stdout
        Unix.stderr
    in
    if pid <> 0 then
      let (_p, status) = Unix.wait () in
      match status with
      | Unix.WEXITED n | Unix.WSIGNALED n | Unix.WSTOPPED n -> Stdlib.exit n
  in
  Cmd.v
    (Cmd.info
       "catala-format"
       ~doc:
         "Format the given $(b,FILE) and output the result.\n\
          When no $(b,FILE) is provided, the standard input will be read\n\
          however the $(b,--language) argument becomes mandatory. ")
    Term.(const f $ language $ file)

let () =
  let open Cmdliner in
  match Cmd.eval ~catch:false ~argv:Sys.argv format_cmd with
  | 0 -> exit Cmd.Exit.ok
  | n -> exit n
  | exception e ->
      Format.eprintf "Unexpected error: %s@." (Printexc.to_string e) ;
      exit Cmd.Exit.some_error
