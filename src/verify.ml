external promise_all7 :
     'a0 Js.Promise.t
     * 'a1 Js.Promise.t
     * 'a2 Js.Promise.t
     * 'a3 Js.Promise.t
     * 'a4 Js.Promise.t
     * 'a5 Js.Promise.t
     * 'a6 Js.Promise.t
  -> ('a0 * 'a1 * 'a2 * 'a3 * 'a4 * 'a5 * 'a6) Js.Promise.t = "all"
[@@mel.scope "Promise"]

external promise_all8 :
     'a0 Js.Promise.t
     * 'a1 Js.Promise.t
     * 'a2 Js.Promise.t
     * 'a3 Js.Promise.t
     * 'a4 Js.Promise.t
     * 'a5 Js.Promise.t
     * 'a6 Js.Promise.t
     * 'a7 Js.Promise.t
  -> ('a0 * 'a1 * 'a2 * 'a3 * 'a4 * 'a5 * 'a6 * 'a7) Js.Promise.t = "all"
[@@mel.scope "Promise"]

let sleep time resolve_with =
  Js.Promise.make (fun ~resolve ~reject ->
      let _ = reject in
      Js.Global.setTimeout ~f:(fun () -> (resolve resolve_with [@u])) time
      |> ignore )

let verify (election : State.t) : Verification.t Js.Promise.t =
  (* { metadata= Metadata.build election *)
  (* (* ; files= Belt.Array.map election.files File.verify_one *) *)
  (* ; files= File.verify election *)
  (* ; setup= Setup.verify election *)
  (* (* ; ballots= Belt.Array.map election.ballots Ballot.verify_one *) *)
  (* ; ballots= Ballot.verify election *)
  (* ; encrypted_tally= Encrypted_tally.verify election *)
  (* (* ; partial_decryptions= *) *)
  (* (*     Belt.Array.map election.partial_decryptions (fun pd -> *) *)
  (* (*         Partial_decryption.verify_one election pd ) *) *)
  (* ; partial_decryptions= Partial_decryption.verify election *)
  (* ; result= Result.verify election *)
  (* ; totals= Totals.verify election } *)
  Js.log election ;
  promise_all7
    ( File.verify election
    , Setup.verify election
    , Ballot.verify election
    , Encrypted_tally.verify election
    , Partial_decryption.verify election
    , Result.verify election
    , Totals.verify election )
  |> Js.Promise.then_
       (fun
         ( files
         , setup
         , ballots
         , encrypted_tally
         , partial_decryptions
         , result
         , totals )
       ->
         { Verification.files
         ; setup
         ; ballots
         ; encrypted_tally
         ; partial_decryptions
         ; result
         ; totals }
         |> Js.Promise.resolve )
(* simulate verification time in development *)
(* |> Js.Promise.then_ (fun election -> sleep 1000 election) *)
