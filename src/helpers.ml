let get_element_by_id id =
  let document = Webapi.Dom.document in
  Webapi.Dom.Document.getElementById id document |> Belt.Option.getUnsafe
