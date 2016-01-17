open Lwt.Infix

let cleanup l : Yojson.Basic.json list =
  l |> List.map begin fun a_line ->
    let chopped =
      Stringext.full_split a_line ~on:' ' |>
      List.filter begin fun str ->
        if str = " " then false else true
      end |>
      Array.of_list in
    `Assoc [("USER", `String chopped.(0));
            ("PID", `Int (int_of_string chopped.(1)));
            ("COMMAND", `String chopped.(10))]
  end

let program =
  let command = Lwt_process.shell "ps aux" in
  let stream = Lwt_process.pread_lines command in
  Lwt_stream.to_list stream >>= fun ps_output ->
  let cleaned = cleanup (List.tl ps_output) in
  cleaned |> Lwt_list.iter_s begin fun the_json ->
    Yojson.Basic.pretty_to_string the_json |> Lwt_io.printl
  end

let () =
  Lwt_main.run program
