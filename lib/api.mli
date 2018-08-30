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

type any_handler = Handler: 'a handler -> any_handler

type 'a handlers

val empty : 'a handlers

val append : 'a handlers -> 'a handlers -> 'a handlers

val register :
     Httpaf.Method.t
  -> Core.String.t
  -> 'a rest_handler
  -> 'a handlers
  -> 'a handlers

val register_any :
     Httpaf.Method.t
  -> Core.String.t
  -> any_handler
  -> 'a handlers
  -> 'a handlers

val get :
     Core.String.t
  -> [`Without_request] handler
  -> 'a handlers
  -> 'a handlers

val put :
     Core.String.t
  -> [`With_request] handler
  -> 'a handlers
  -> 'a handlers

val post :
     Core.String.t
  -> [`With_request] handler
  -> 'a handlers
  -> 'a handlers

val delete :
     Core.String.t
  -> [`Without_request] handler
  -> 'a handlers
  -> 'a handlers

val process : 'a handlers -> 'a Httpaf.Reqd.t -> unit
