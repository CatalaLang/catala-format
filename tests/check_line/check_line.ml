open Lwt.Syntax

let main ?(max_len = 80) path =
  Lwt_io.with_file ~mode:Input path
  @@ fun ic ->
  let lines = Lwt_io.read_lines ic in
  let res = ref [] in
  let cpt = ref 1 in
  let is_in_code_block = ref false in
  let* () =
    Lwt_stream.iter_s
      (fun line ->
        if
          String.length line > 2
          && line.[0] = '`'
          && line.[1] = '`'
          && line.[2] = '`'
        then is_in_code_block := not !is_in_code_block;
        let nline = Ubase.from_utf8 line in
        let len = String.length nline in
        if len > max_len then
          res := (!is_in_code_block, len, !cpt, line) :: !res;
        incr cpt;
        Lwt.return_unit)
      lines
  in
  if !res = [] then Format.printf "[No lines are larger than %d]@." max_len
  else begin
    let code, text =
      List.partition_map
        (function
          | true, a, b, c -> Either.left (a, b, c)
          | false, a, b, c -> Either.right (a, b, c))
        (List.rev !res)
    in
    let print_line (width, cpt, _) =
      Format.printf "File \"%s\", line %d, characters 0-%d@." path cpt width
    in
    let print_text () =
      Format.printf "[Found %d law text lines that are larger than %d]@."
        (List.length text) max_len;
      List.iter print_line text
    in
    let print_code () =
      Format.printf "[Found %d code lines that are larger than %d]@."
        (List.length code) max_len;
      List.iter print_line code
    in
    match Sys.getenv_opt "KIND" with
    | Some "code" -> print_code ()
    | Some "text" -> print_text ()
    | _ ->
      print_text ();
      print_code ()
  end;

  Lwt.return_unit

let () =
  Lwt_main.run
  @@
  match Sys.argv with
  | [| _; file |] -> main file
  | [| _; file; max_len |] -> main ~max_len:(int_of_string max_len) file
  | _ -> invalid_arg "Usage: ./check_line.exe <FILE> [<MAX LINE LENGTH>]"
