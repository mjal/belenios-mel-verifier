let display_questions (questions : State.question array) =
  let open Webapi.Dom in
  let document = document in
  let question_list = Display.get_element_by_id "info-questions" in
  Belt.Array.forEach questions (fun question ->
      let question_item = Document.createElement "li" document in
      let question_text = Document.createElement "span" document in
      Element.setInnerText question_text question.question ;
      Element.appendChild question_text question_item ;
      let answer_list = Document.createElement "ul" document in
      Element.setAttribute "class" "uk-list uk-list-disc" answer_list ;
      Belt.Array.forEach question.answers (fun answer ->
          let answer_item = Document.createElement "li" document in
          let answer_text = Document.createElement "span" document in
          Element.setInnerText answer_text answer ;
          Element.appendChild answer_text answer_item ;
          Element.appendChild answer_item answer_list ) ;
      Element.appendChild answer_list question_item ;
      Element.appendChild question_item question_list )

let display_metadata _state =
  let state = Belt.Option.getUnsafe !State.current in
  let setup = state.State.setup.payload.election in
  Display.set_field "info-name" setup.name ;
  Display.set_field "info-description" setup.description ;
  Display.set_field "info-hash" setup.public_key ;
  display_questions setup.questions

let display_ballots ?search () =
  Js.log search ;
  let open Webapi.Dom in
  let document = document in
  let ballots_list = Display.get_element_by_id "ballots-list" in
  Element.setInnerHTML ballots_list "" ;
  let state = Belt.Option.getUnsafe !State.current in
  state.State.ballots
  |. Belt.Array.map (fun ballot -> ballot.payload.credential)
  |. Belt.Set.String.fromArray
  |. Belt.Set.String.keep (fun ballot_hash ->
         match search with
         | Some search_string ->
             Js.String.startsWith ~prefix:search_string ballot_hash
         | None ->
             true )
  |. Belt.Set.String.forEach (fun ballot_hash ->
         let ballot_item = Document.createElement "li" document in
         let ballot_text = Document.createElement "span" document in
         Element.setInnerText ballot_text ballot_hash ;
         Element.appendChild ballot_text ballot_item ;
         Element.appendChild ballot_item ballots_list )

let display_ballot_generation_form _state =
  let open Webapi.Dom in
  let document = document in
  let state = Belt.Option.getUnsafe !State.current in
  let questions = state.State.setup.payload.election.questions in
  let question_list = Display.get_element_by_id "generate-ballot-questions" in
  Belt.Array.forEachWithIndex questions (fun index_question question ->
      let question_item = Document.createElement "div" document in
      Element.setAttribute "class" "uk-margin" question_item ;
      let question_text = Document.createElement "label" document in
      Element.setAttribute "class" "uk-form-label" question_text ;
      (* Webapi.Dom.Element.setAttribute "for" ("generate-ballot-question-" ^ string_of_int index) question_text ; *)
      Element.setInnerText question_text question.question ;
      Element.appendChild question_text question_item ;
      let answer_list = Document.createElement "div" document in
      Element.setAttribute "class" "uk-form-controls" answer_list ;
      Belt.Array.forEachWithIndex question.answers (fun index_answer answer ->
          let answer_item = Document.createElement "label" document in
          let answer_input = Document.createElement "input" document in
          Element.setAttribute "class"
            "uk-radio generate-ballot-input generate-ballot-answer" answer_input ;
          Element.setAttribute "type" "radio" answer_input ;
          Element.setAttribute "name"
            ("generate-ballot-input-" ^ string_of_int index_question)
            answer_input ;
          Element.setAttribute "value"
            (string_of_int index_answer)
            answer_input ;
          let answer_text = Document.createTextNode (" " ^ answer) document in
          let line_break = Document.createElement "br" document in
          Element.appendChild answer_input answer_item ;
          Element.appendChild answer_text answer_item ;
          Element.appendChild line_break answer_item ;
          Element.appendChild answer_item answer_list ) ;
      Element.appendChild answer_list question_item ;
      Element.appendChild question_item question_list ) ;
  Document.getElementsByClassName "generate-ballot-input" document
  |. HtmlCollection.toArray
  |. Belt.Array.forEach (fun input ->
         Element.addEventListener "input"
           (fun _ -> Generate_ballot.generate ())
           input )

let display_verifications _state verificationState =
  Display.add_status_info ~pass:"Totals weight is correct"
    ~fail:"Totals weight is incorrect"
    verificationState.Verification.totals.weight ;
  Display.add_status_info ~pass:"Totals amount is correct"
    ~fail:"Totals amount is incorrect" verificationState.totals.amount


let display_results state verificationState =
  let state = Belt.Option.getExn state in
  let verificationState = Belt.Option.getExn verificationState in
  display_metadata state ;
  display_ballots () ;
  display_verifications state verificationState ;
  display_ballot_generation_form state ;
  Display.unset_spinner () |. Js.Promise.resolve

let () =
  let open Webapi.Dom in
  let file_input = Display.get_element_by_id "file" in
  let () =
    Element.addEventListener "change"
      (fun _ ->
        Display.set_spinner () ;
        Loader.load_file ~after:display_results file_input )
      file_input
  in
  let ballot_search_input = Display.get_element_by_id "ballots-search" in
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
        display_ballots ?search () )
      ballot_search_input
  in
  (* these next 2 lines are for development *)
  (*
  State.current := Some State.fake_state ;
  let _ = Display.display_results Verification.fake_verification in
  *)
  ()
