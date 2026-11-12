let () =
  let hash = read_line () |> String.trim in
  let lang_to_conf (l : Locale.language) =
    Printf.sprintf
      {ncl|    catala_%s = {
      extensions = ["catala_%s", "catala_%s.md"],
      grammar = {
        source = {
          git = {
            git = "https://github.com/CatalaLang/tree-sitter-catala.git",
            rev = "%s",
            subdir = "catala_%s",
          }
        }
      }
    }|ncl}
      l.code l.code l.code hash l.code
  in
  let languages =
    List.map snd (Languages.languages ())
    |> List.map lang_to_conf
    |> String.concat ",\n"
  in
  print_endline @@ {ncl|{
  languages = {
|ncl} ^ languages ^ {ncl|
  }
}|ncl}
