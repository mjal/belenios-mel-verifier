let set_spinner () =
  let import = Helpers.get_element_by_id "import" in
  let spinner = Helpers.get_element_by_id "spinner" in
  let open Webapi.Dom in
  import |> Element.classList |> DomTokenList.add "uk-hidden" ;
  spinner |> Element.classList |> DomTokenList.remove "uk-hidden"

let unset_spinner () =
  let content = Helpers.get_element_by_id "content" in
  let spinner = Helpers.get_element_by_id "spinner" in
  let open Webapi.Dom in
  content |> Element.classList |> DomTokenList.remove "uk-hidden" ;
  spinner |> Element.classList |> DomTokenList.add "uk-hidden"

let set_field id text =
  Helpers.get_element_by_id id |. Webapi.Dom.Element.setInnerText text

let display_questions (questions : State.question array) =
  let open Webapi.Dom in
  let document = document in
  let question_list = Helpers.get_element_by_id "info-questions" in
  Belt.Array.forEach questions (fun question ->
      let question_item = Document.createElement "li" document in
      let question_text = Document.createElement "span" document in
      Element.setInnerText question_text question.question ;
      Element.appendChild question_text question_item ;
      let answer_list = Document.createElement "ul" document in
      Webapi.Dom.Element.setAttribute "class" "uk-list uk-list-disc" answer_list ;
      Belt.Array.forEach question.answers (fun answer ->
          let answer_item = Document.createElement "li" document in
          let answer_text = Document.createElement "span" document in
          Element.setInnerText answer_text answer ;
          Element.appendChild answer_text answer_item ;
          Element.appendChild answer_item answer_list ) ;
      Element.appendChild answer_list question_item ;
      Element.appendChild question_item question_list )

let display_metadata () =
  let state = Belt.Option.getUnsafe !State.current in
  let setup = state.State.setup.payload.election in
  set_field "info-name" setup.name ;
  set_field "info-description" setup.description ;
  set_field "info-hash" setup.public_key ;
  display_questions setup.questions

let display_ballots ?search () =
  Js.log search ;
  let open Webapi.Dom in
  let document = document in
  let ballots_list = Helpers.get_element_by_id "ballots-list" in
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

let set_total_fail () =
  let element = Helpers.get_element_by_id "verifications-total" in
  Webapi.Dom.Element.setAttribute "uk-icon" "close" element ;
  Webapi.Dom.Element.setAttribute "class"
    "uk-text-danger uk-display-inline-block" element

let create_status_info ~pass ~fail status =
  let icon = if status then "check" else "close" in
  let color = if status then "uk-text-success" else "uk-text-danger" in
  let tooltip = if status then pass else fail in
  let document = Webapi.Dom.document in
  let element = Webapi.Dom.Document.createElement "a" document in
  Webapi.Dom.Element.setAttribute "uk-icon" icon element ;
  Webapi.Dom.Element.setAttribute "class" color element ;
  Webapi.Dom.Element.setAttribute "uk-tooltip" tooltip element ;
  element

let add_status_info ~pass ~fail status =
  if not status then set_total_fail () ;
  let element = create_status_info ~pass ~fail status in
  let container = Helpers.get_element_by_id "verifications" in
  Webapi.Dom.Element.appendChild element container

let display_verifications verificationState =
  add_status_info ~pass:"Totals weight is correct"
    ~fail:"Totals weight is incorrect"
    verificationState.Verification.totals.weight ;
  add_status_info ~pass:"Totals amount is correct"
    ~fail:"Totals amount is incorrect" verificationState.totals.amount

let display_ballot_generation_form () =
  let open Webapi.Dom in
  let document = document in
  let state = Belt.Option.getUnsafe !State.current in
  let questions = state.State.setup.payload.election.questions in
  let question_list = Helpers.get_element_by_id "generate-ballot-questions" in
  Belt.Array.forEachWithIndex questions (fun index_question question ->
      let question_item = Document.createElement "div" document in
      Webapi.Dom.Element.setAttribute "class" "uk-margin" question_item ;
      let question_text = Document.createElement "label" document in
      Webapi.Dom.Element.setAttribute "class" "uk-form-label" question_text ;
      (* Webapi.Dom.Element.setAttribute "for" ("generate-ballot-question-" ^ string_of_int index) question_text ; *)
      Element.setInnerText question_text question.question ;
      Element.appendChild question_text question_item ;
      let answer_list = Document.createElement "div" document in
      Webapi.Dom.Element.setAttribute "class" "uk-form-controls" answer_list ;
      Belt.Array.forEachWithIndex question.answers (fun index_answer answer ->
          let answer_item = Document.createElement "label" document in
          let answer_input = Document.createElement "input" document in
          Webapi.Dom.Element.setAttribute "class"
            "uk-radio generate-ballot-input generate-ballot-answer" answer_input ;
          Webapi.Dom.Element.setAttribute "type" "radio" answer_input ;
          Webapi.Dom.Element.setAttribute "name"
            ("generate-ballot-input-" ^ string_of_int index_question)
            answer_input ;
          Webapi.Dom.Element.setAttribute "value"
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

let display_results election =
  display_metadata () ;
  display_ballots () ;
  display_verifications election ;
  display_ballot_generation_form () ;
  unset_spinner () |. Js.Promise.resolve
