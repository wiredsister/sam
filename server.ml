open Lwt.Infix

let program =
  let command = Lwt_process.shell "ps aux" in
  let stream = Lwt_process.pread_lines command in
  Lwt_stream.to_list stream >>= fun ps_output ->
  Lwt.return (List.iter print_endline ps_output)


let () =
  Lwt_main.run program
