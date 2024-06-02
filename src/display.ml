let get_element_by_id id =
  let open Webapi.Dom in
  Document.getElementById id document |> Belt.Option.getUnsafe

let hide el =
  let open Webapi.Dom in
  el |> Element.classList |> DomTokenList.add "uk-hidden"

let show el =
  let open Webapi.Dom in
  el |> Element.classList |> DomTokenList.remove "uk-hidden"

let set_spinner () =
  get_element_by_id "import" |> hide;
  get_element_by_id "spinner" |> show

let unset_spinner () =
  get_element_by_id "content" |> show;
  get_element_by_id "spinner" |> hide

let set_field id text =
  get_element_by_id id |. Webapi.Dom.Element.setInnerText text

let set_total_fail () =
  let element = get_element_by_id "verifications-total" in
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
  let container = get_element_by_id "verifications" in
  Webapi.Dom.Element.appendChild element container

