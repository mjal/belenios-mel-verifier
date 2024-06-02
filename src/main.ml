let () =
  let open Webapi.Dom in
  let file_input = Helpers.get_element_by_id "file" in
  let () =
    Element.addEventListener "change"
      (fun _ ->
        Display.set_spinner () ;
        Loader.load_file ~after:Display.display_results file_input )
      file_input
  in
  let ballot_search_input = Helpers.get_element_by_id "ballots-search" in
  let () =
    Element.addEventListener "input"
      (fun event ->
        Js.log event ;
        let target = Event.target event in
        let search =
          match
            EventTarget.unsafeAsElement target |> HtmlInputElement.ofElement
          with
          | Some input_element ->
              let value = HtmlInputElement.value input_element in
              if value == "" then Option.None else Some value
          | None ->
              None
        in
        Display.display_ballots ?search () )
      ballot_search_input
  in
  (* these next 2 lines are for development *)
  State.current := Some State.fake_state ;
  let _ = Display.display_results Verification.fake_verification in
  ()
