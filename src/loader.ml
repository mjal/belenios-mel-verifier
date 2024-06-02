external element_files : Dom.element -> Webapi.File.t array = "files"
[@@mel.get]

type reader = {result: Js.Typed_array.ArrayBuffer.t}

external new_reader : unit -> reader = "FileReader"
[@@mel.scope "window"] [@@mel.new]

external reader_set_onload : reader -> (unit -> unit) -> unit = "onload"
[@@mel.set]

external reader_read_as_array_buffer : reader -> Webapi.File.t -> unit
  = "readAsArrayBuffer"
[@@mel.send]

(* file object from untar *)
(* https://github.com/InvokIT/js-untar?tab=readme-ov-file#file-object *)
type file = {name: string}

external untar : Js.Typed_array.ArrayBuffer.t -> file array Js.Promise.t
  = "default"
[@@mel.module "js-untar"]

external load : file array -> State.t = "default" [@@mel.module "./load.js"]

let first_file input = element_files input |. Belt.Array.getExn 0

let read_file on_read file =
  let reader = new_reader () in
  reader_set_onload reader (fun _ -> on_read reader.result |> ignore) ;
  reader_read_as_array_buffer reader file

let load_file tar_file then_ =
  read_file
    (fun file ->
      untar file
      |> Js.Promise.then_ (fun files ->
             load files |> Js.Promise.resolve
             |> Js.Promise.then_ (fun state ->
                    State.current := Some state ;
                    Verify.verify state )
             |> Js.Promise.then_ (fun verification ->
                    Verification.current := Some verification ;
                    then_ !State.current !Verification.current ) ) )
    tar_file
