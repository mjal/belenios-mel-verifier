open Verification.Result

(* TODO *)
let verify _election =
  { decryption_factors= [|Single false; Pedersen false|]
  ; result= [|false; false; false|] }
  |> Js.Promise.resolve
