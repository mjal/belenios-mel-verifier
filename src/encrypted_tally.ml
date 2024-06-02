open Verification.Encrypted_tally

(* TODO *)
let verify _election =
  {microballot_weight= [|false|]; weight= false; num_tallied= false}
  |> Js.Promise.resolve
