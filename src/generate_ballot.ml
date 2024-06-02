let get_private_key () =
  let open Webapi.Dom in
  Display.get_element_by_id "generate-ballot-private-key"
  |. HtmlInputElement.ofElement |. Belt.Option.getUnsafe
  |. HtmlInputElement.value

let get_answers () =
  let open Webapi.Dom in
  Document.getElementsByClassName "generate-ballot-answer" document
  |. HtmlCollection.toArray
  |. Belt.Array.keep (fun input ->
         input |. HtmlInputElement.ofElement |. Belt.Option.getUnsafe
         |. HtmlInputElement.checked )
  |. Belt.Array.map (fun input ->
         input |. HtmlInputElement.ofElement |. Belt.Option.getUnsafe
         |. HtmlInputElement.value |. int_of_string )

let set_ballot_textarea ballot_json =
  let open Webapi.Dom in
  Display.get_element_by_id "generate-ballot-ballot"
  |. Element.setInnerHTML ballot_json

let generate () =
  Js.log "Generating ballot" ;
  let state = Belt.Option.getUnsafe !State.current in
  let private_key = get_private_key () in
  let answers = get_answers () in
  if
    Belt.Array.length answers
    == Belt.Array.length state.setup.payload.election.questions
  then
    let answers_json =
      Belt.Array.mapWithIndex answers (fun answer_index answer ->
          "Question " ^ string_of_int answer_index ^ " -> answer "
          ^ string_of_int answer )
      |. Belt.Array.joinWith "\n" Fun.id
    in
    let ballot_json = private_key ^ "\n" ^ answers_json in
    set_ballot_textarea ballot_json
