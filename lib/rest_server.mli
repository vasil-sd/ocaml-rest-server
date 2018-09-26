module Path : sig
  module Var : sig
    type vars

    val get : vars -> string -> string option
  end

  type t

  val from_string : Core.String.t -> t

  val match_path : t -> t -> Var.vars option
end

module Http_json : sig
  val response_error :
       ?error:Httpaf.Status.standard
    -> ?text:string
    -> 'a Httpaf.Reqd.t
    -> unit

  val response_ok :
    ?text:string -> 'a Httpaf.Reqd.t -> unit

  val response_json :
    'a Httpaf.Reqd.t -> Yojson.Safe.json -> unit

  val request_json :
       'a Httpaf.Reqd.t
    -> ('a Httpaf.Reqd.t -> Yojson.Safe.json -> unit)
    -> unit
end

module Api : sig
  type responded

  type response =
    { response_error:
           ?error:Httpaf.Status.standard
        -> ?text:string
        -> unit
        -> responded
    ; response_ok: ?text:string -> unit -> responded
    ; response_json: Yojson.Safe.json -> responded
    ; get_path_var: Core.String.t -> Core.String.t option
    }

  exception Path_Conflict

  type 'a rest_handler =
    'a Httpaf.Reqd.t -> Rest_path.Var.vars -> unit

  type _ handler =
    | Without_request :
        (response -> responded)
        -> [`Without_request] handler
    | With_request :
        (response -> Yojson.Safe.json -> responded)
        -> [`With_request] handler

  type any_handler = Handler : 'a handler -> any_handler

  type 'a handlers

  val empty : 'a handlers

  val register :
       Httpaf.Method.t
    -> Core.String.t
    -> 'a rest_handler
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
end

module Swagger = Swagger

val of_swagger :
  Swagger.swagger -> 'a Api.handlers -> 'a Api.handlers

val main : Async.Fd.t Api.handlers -> unit
