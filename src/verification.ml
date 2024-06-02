module File = struct
  type t = {contents: bool array; event_chain: bool}
end

module Setup = struct
  type public_key = {curve_point: bool; matches_trustees: bool}

  type t = {trustees: bool array; public_key: bool; credentials: bool array}
end

module Ballot = struct
  type overall_proof =
    | WithoutBlank of bool
    | WithBlank of {blank: bool; overall: bool}

  type answer = {individual_proof: bool; overall_proof: overall_proof}

  type t =
    { hash: string
    ; uuid: bool
    ; hash_status: bool
    ; canonical: bool
    ; credentials: bool
    ; is_unique: bool
    ; valid_points: bool
    ; signature: bool
    ; answers: answer array }
end

module Encrypted_tally = struct
  type t = {microballot_weight: bool array; weight: bool; num_tallied: bool}
end

module Result = struct
  type decryption_factor = Single of bool | Pedersen of bool

  type t = {decryption_factors: decryption_factor array; result: bool array}
end

module Totals = struct
  type t = {weight: bool; amount: bool}
end

type t =
  { files: File.t
  ; setup: Setup.t
  ; ballots: Ballot.t array
  ; encrypted_tally: Encrypted_tally.t
  ; partial_decryptions: bool array
  ; result: Result.t
  ; totals: Totals.t }

let current : t option ref = ref None

let fake_verification =
  { files= {contents= [|true; false; true|]; event_chain= true}
  ; setup=
      { trustees= [|true; true; false|]
      ; public_key= true
      ; credentials= [|true; true; false|] }
  ; ballots=
      [| { hash= "hash1"
         ; uuid= true
         ; hash_status= true
         ; canonical= true
         ; credentials= true
         ; is_unique= true
         ; valid_points= true
         ; signature= true
         ; answers=
             [| {individual_proof= true; overall_proof= WithoutBlank true}
              ; { individual_proof= true
                ; overall_proof= WithBlank {blank= true; overall= true} } |] }
       ; { hash= "hash2"
         ; uuid= true
         ; hash_status= false
         ; canonical= true
         ; credentials= true
         ; is_unique= false
         ; valid_points= true
         ; signature= true
         ; answers=
             [| {individual_proof= false; overall_proof= WithoutBlank true}
              ; { individual_proof= true
                ; overall_proof= WithBlank {blank= true; overall= true} } |] }
      |]
  ; encrypted_tally=
      {microballot_weight= [|true; true|]; weight= true; num_tallied= true}
  ; partial_decryptions= [|true; true; false|]
  ; result=
      { decryption_factors= [|Single true; Pedersen false|]
      ; result= [|true; true; false|] }
  ; totals= {weight= true; amount= false} }
