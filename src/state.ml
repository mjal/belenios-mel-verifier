type proof = {challenge: string; response: string}

type partial_decryption =
  {decryption_factors: string array array; decryption_proofs: proof array array}

type owned_partial_decryption = {owner: int; payload: partial_decryption}

type 'a event = {parent: string; height: int; _type: string; payload: 'a}

type file = string * string * int event

type ballot_payload = {credential: string}

type ballot = {payload: ballot_payload}

type question = {question: string; answers: string array}

type setup_election =
  { name: string
  ; description: string
  ; questions: question array
  ; public_key: string }

type setup_payload = {election: setup_election}

type setup = {payload: setup_payload}

type t =
  { files: file array
  ; ballots: ballot array
  ; partialDecryptions: owned_partial_decryption event array
  ; encryptedTally: int
  ; setup: setup }

let current : t option ref = ref None

let fake_state =
  { files= [||]
  ; ballots=
      [|{payload= {credential= "hash1"}}; {payload= {credential= "hash2"}}|]
  ; partialDecryptions= [||]
  ; encryptedTally= 42
  ; setup=
      { payload=
          { election=
              { name= "Fake election"
              ; description= "Fake description"
              ; questions=
                  [| { question= "Question 1"
                     ; answers= [|"Answer 1"; "Answer 2"|] }
                   ; { question= "Question 2"
                     ; answers= [|"Answer 1"; "Answer 2"|] } |]
              ; public_key= "FakePublicKey" } } } }
