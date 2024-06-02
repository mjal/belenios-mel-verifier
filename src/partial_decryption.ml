(* TODO *)
let verify_one _state pd =
  let () = Js.log pd in
  false

let verify state =
  Belt.Array.map state.State.partialDecryptions (fun pd -> verify_one state pd)
  |> Js.Promise.resolve
