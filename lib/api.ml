open Core
open Httpaf
open Http_json

exception Path_Conflict

type 'a t =
  { path: Rest_path.t
  ; meth: Httpaf.Method.t
  ; handler:
         'a Httpaf.Reqd.t
      -> Request.t
      -> Rest_path.Var.vars
      -> unit }

type 'a handlers = 'a t Core.List.t

let empty : 'a handlers = []

let register meth path handler hs =
  let path = Rest_path.convert path in
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

let get path handler hs = register `GET path handler hs
let put path handler hs = register `PUT path handler hs
let post path handler hs = register `POST path handler hs
let delete path handler hs = register `DELETE path handler hs

let process hs reqd =
  let req = Reqd.request reqd in
  let rpath = Rest_path.convert req.target in
  let rmeth = req.meth in
  let h =
    List.find
      ~f:(fun {path; meth; handler} ->
        rmeth = meth
        &&
        match
          Rest_path.match_path rpath path
        with
        | None -> false
        | Some vars ->
            handler reqd req vars ;
            true )
      hs
  in
  match h with
  | None ->
      response_error ~error:`Not_found
        ~text:"REST method not found!" reqd
  | Some _ -> ()
