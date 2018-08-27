type response =
  { response_error:
         ?error:Httpaf.Status.standard
      -> ?text:string
      -> unit
      -> unit
  ; response_ok: unit -> unit
  ; response_json: Yojson.Safe.json -> unit
  ; get_path_var: Core.String.t -> Core.String.t option }

exception Path_Conflict

type 'a handlers

val empty : 'a handlers

val register :
     Httpaf.Method.t
  -> Core.String.t
  -> ('a Httpaf.Reqd.t -> Rest_path.Var.vars -> unit)
  -> 'a handlers
  -> 'a handlers

val get :
     Core.String.t
  -> (response -> unit)
  -> 'a handlers
  -> 'a handlers

val put :
     Core.String.t
  -> (response -> Yojson.Safe.json -> unit)
  -> 'a handlers
  -> 'a handlers

val post :
     Core.String.t
  -> (response -> Yojson.Safe.json -> unit)
  -> 'a handlers
  -> 'a handlers

val delete :
     Core.String.t
  -> (response -> unit)
  -> 'a handlers
  -> 'a handlers

val process : 'a handlers -> 'a Httpaf.Reqd.t -> unit
