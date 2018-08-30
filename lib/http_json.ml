open Core
open Httpaf

let response_error
    ?(error= `Internal_server_error) ?text
    reqd =
  let response =
    Response.create
      ~headers:
        (Headers.of_list
           [ ("content-type", "text/plain")
           ; ("connection", "close") ])
      ( error
        :> [ Httpaf.Status.standard
           | `Code of int ] )
  in
  let response_body =
    Reqd.respond_with_streaming reqd
      response
  in
  Body.write_string response_body
    ( match text with
    | None ->
        Status.default_reason_phrase error
    | Some text -> text ) ;
  Body.close_writer response_body

let response_ok ?text reqd = response_error ?text ~error:`OK reqd

let response_json reqd json =
  let response =
    Response.create
      ~headers:
        (Headers.of_list
           [ ( "content-type"
             , "application/json" )
           ; ("connection", "close") ])
      `OK
  in
  let response_body =
    Reqd.respond_with_streaming reqd
      response
  in
  let output_substr =
    object
      method output str off len =
        Body.write_string response_body ~off ~len str ;
        len
    end
  in
  json
  |> Yojson.Safe.to_output output_substr ;
  Body.close_writer response_body

let request_json reqd handler =
  let req = Reqd.request reqd in
  match
    Headers.get req.Request.headers
      "content-type"
  with
  | Some "application/json" ->
      let buffer = Buffer.create 256 in
      let request_body =
        Reqd.request_body reqd
      in
      let rec on_read buff ~off ~len =
        buff
        |> Bigstring.to_string ~off ~len
        |> Buffer.add_string buffer ;
        Body.schedule_read request_body
          ~on_eof ~on_read
      and on_eof () =
        try
          Buffer.contents buffer
          |> Yojson.Safe.from_string
          |> handler reqd
        with _ ->
          response_error
            ~error:`Unsupported_media_type
            ~text:"Ill-formed JSON" reqd
      in
      Body.schedule_read
        (Reqd.request_body reqd)
        ~on_eof ~on_read
  | _ ->
      response_error
        ~error:`Unsupported_media_type
        ~text:
          "Only application/json MIME type \
           is supported"
        reqd

