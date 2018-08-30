open Core
open Async
open Httpaf
open Httpaf_async
module Path = Rest_path
module Http_json = Http_json
module Api = Api

module Swagger = Swagger

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

let (>?) o v =
  match o with
  | None -> v
  | Some v -> v

let of_swagger swagger hs =
  let open Swagger in
  let base_path = swagger.base_path >? "" in
  let paths = swagger.paths in
  let process_path_item (path, path_item) =
    List.fold_left
    ~f:(fun acc (meth, op) -> 
        match op with
        | None -> acc
        | Some op -> Api.register_any meth (base_path ^ path) op.handler acc)
    ~init:Api.empty
    [(`GET, path_item.get);
     (`PUT, path_item.put);
     (`POST, path_item.post);
     (`DELETE, path_item.delete)]
  in
  List.map ~f:process_path_item paths
  |> List.fold_left ~f:Api.append ~init:hs
  |> Api.get (base_path ^ "/swagger.json")
             (Api.Without_request
               (fun {Api.response_ok;_ } -> 
                 response_ok ~text:(string_of_swagger swagger) ()))