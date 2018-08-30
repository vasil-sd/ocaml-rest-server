open Core
open Httpaf
open Http_json

type response =
  { response_error:
         ?error:Httpaf.Status.standard
      -> ?text:string
      -> unit
      -> unit
  ; response_ok: ?text:string -> unit -> unit
  ; response_json: Yojson.Safe.json -> unit
  ; get_path_var: Core.String.t -> Core.String.t option }

exception Path_Conflict

type 'a rest_handler = 'a Httpaf.Reqd.t -> Rest_path.Var.vars -> unit

type _ handler =
  | Without_request : (response -> unit) -> [`Without_request] handler
  | With_request : (response -> Yojson.Safe.json -> unit) -> [`With_request] handler

type any_handler = Handler : 'a handler -> any_handler

type 'a t =
  { path: Rest_path.t
  ; meth: Httpaf.Method.t
  ; handler: 'a rest_handler
  }

type 'a handlers = 'a t Core.List.t

let empty : 'a handlers = []

let append a b = List.append a b

let register meth path handler hs =
  let path = Rest_path.from_string path in
  let option_to_bool = function
    | None -> false
    | Some _ -> true
  in
  let chk =
    List.find
      ~f:(fun elt ->
        meth = elt.meth
        && Rest_path.match_path path elt.path
           |> option_to_bool )
      hs
  in
  match chk with
  | Some _ -> raise Path_Conflict
  | None -> {path; meth; handler} :: hs

let make_response reqd vars =
  let response_error ?error ?text () =
    Http_json.response_error ?error ?text reqd
  and response_ok ?text () = Http_json.response_ok ?text reqd
  and response_json json =
    Http_json.response_json reqd json
  and get_path_var v = Rest_path.Var.get vars v in
  {response_error; response_ok; response_json; get_path_var}

let wrap_handler (type t) (handler : t handler) : 'a rest_handler =
  let handler_without_request handler reqd vars =
    let r = make_response reqd vars in handler r
  in
  let handler_with_request handler reqd vars =
    let r = make_response reqd vars in
    let handler _ json = handler r json in
    Http_json.request_json reqd handler
  in
  match handler with
  | Without_request h -> handler_without_request h
  | With_request h -> handler_with_request h

let register_any meth path (Handler handler) hs =
  register meth path (wrap_handler handler) hs

let get path (handler : [`Without_request] handler) hs =
  let handler = wrap_handler handler in
  register `GET path handler hs

let delete path (handler : [`Without_request] handler) hs =
  let handler = wrap_handler handler in
  register `DELETE path handler hs

let put path (handler : [`With_request] handler) hs =
  let handler = wrap_handler handler in
  register `PUT path handler hs

let post path (handler : [`With_request] handler) hs =
  let handler = wrap_handler handler in
  register `POST path handler hs

let process hs reqd =
  let req = Reqd.request reqd in
  let rpath = Rest_path.from_string req.target in
  let rmeth = req.meth in
  let h =
    List.find
      ~f:(fun {path; meth; handler} ->
        rmeth = meth
        &&
        match Rest_path.match_path rpath path with
        | None -> false
        | Some vars -> handler reqd vars ; true )
      hs
  in
  match h with
  | None ->
      response_error ~error:`Not_found
        ~text:"REST method not found!" reqd
  | Some _ -> ()
