open Lwt.Infix

let addr = Unix.ADDR_INET (Unix.inet_addr_loopback, 5000)

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
  let server = Lwt_io.establish_server addr begin fun (ic, oc) ->
      let command = Lwt_process.shell "ps aux" in
      let stream = Lwt_process.pread_lines command in
      (Lwt_stream.to_list stream >>= fun ps_output ->
       let cleaned = cleanup (List.tl ps_output) in
       cleaned |> Lwt_list.iter_s begin fun the_json ->
         let to_string = Yojson.Basic.pretty_to_string the_json in
         Lwt_io.write_from_string_exactly oc to_string 0 (String.length to_string - 1)
         >>= fun _ -> Lwt_io.write_char oc '\n'
       end
       >>= fun _ -> Lwt_io.close oc)
      |> Lwt.ignore_result
    end
  in
  (* Lwt.wait gives you back (thread, waker) *)
  (* since we don't want the server to ever stop *)
  (* we throw away the wakener *)
  Lwt.wait () |> fst

let () =
  Lwt_main.run program
