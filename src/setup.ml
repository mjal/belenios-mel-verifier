open Verification.Setup

(* TODO *)
let verify _election =
  {trustees= [|false|]; public_key= false; credentials= [|false|]}
  |> Js.Promise.resolve
