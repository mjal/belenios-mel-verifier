open Verification.Ballot

(* TODO *)
let verify_one _ballot =
  { hash= "hash1"
  ; uuid= false
  ; hash_status= false
  ; canonical= false
  ; credentials= false
  ; is_unique= false
  ; valid_points= false
  ; signature= false
  ; answers=
      [| {individual_proof= false; overall_proof= WithoutBlank false}
       ; { individual_proof= false
         ; overall_proof= WithBlank {blank= false; overall= false} } |] }

let verify state =
  Belt.Array.map state.State.ballots verify_one |> Js.Promise.resolve
