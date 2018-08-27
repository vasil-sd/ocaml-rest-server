open Core
open Async
open Httpaf
open Httpaf_async
module Path = Rest_path
module Http_json = Http_json
module Api = Api

let main handlers =
  let error_handler _ ?request error
      start_response =
    let response_body =
      start_response Headers.empty
    in
    ( match error with
    | `Exn exn ->
        Body.write_string response_body
          (Exn.to_string exn) ;
        Body.write_string response_body "\n"
    | #Status.standard as error ->
        Body.write_string response_body
          (Status.default_reason_phrase
             error) ) ;
    Body.close_writer response_body ;
    ignore request
  in
  let request_handler _ reqd =
    Api.process handlers reqd
  in
  let start port max_accepts_per_batch () =
    let where_to_listen =
      Tcp.Where_to_listen.of_port port
    in
    Tcp.(
      Server.create_sock
        ~on_handler_error:`Raise
        ~backlog:10_000
        ~max_connections:10_000
        ~max_accepts_per_batch
        where_to_listen)
      (Server.create_connection_handler
         ~request_handler ~error_handler)
    >>= fun _ -> Deferred.never ()
  in
  Command.async_spec
    ~summary:
      "Start a hello world Async server"
    Command.Spec.(
      empty
      +> flag "-p"
           (optional_with_default 8080 int)
           ~doc:
             "int Source port to listen on"
      +> flag "-a"
           (optional_with_default 1 int)
           ~doc:
             "int Maximum accepts per batch")
    start
  |> Command.run
