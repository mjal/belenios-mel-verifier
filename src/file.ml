open Verification.File

(* TODO *)
let verify_content _file = false

(* TODO *)
let verify_event_chain (files : State.file array) =
  for i = 0 to Array.length files - 1 do
    let entryHash, typ, content = files.(i) in
    let parent = ref None in
    let nEvent = ref 0 in
    if typ = "event" then (
      Display.add_status_info
        ~pass:"Parent field corresponds to previous event's hash"
        ~fail:"Event hash chain missmatch"
        (Some content.parent = !parent) ;
      parent := Some entryHash ;
      incr nEvent )
  done ;
  true

let verify state =
  { contents= Belt.Array.map state.State.files verify_content
  ; event_chain= verify_event_chain state.State.files }
  |> Js.Promise.resolve
