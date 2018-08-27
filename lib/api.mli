exception Path_Conflict
type 'a handlers
val empty : 'a handlers
val register :
  Httpaf.Method.t ->
  Core.String.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Rest_path.Var.vars -> unit) ->
  'a handlers -> 'a handlers
val get :
  Core.String.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Rest_path.Var.vars -> unit) ->
  'a handlers -> 'a handlers
val put :
  Core.String.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Rest_path.Var.vars -> unit) ->
  'a handlers -> 'a handlers
val post :
  Core.String.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Rest_path.Var.vars -> unit) ->
  'a handlers -> 'a handlers
val delete :
  Core.String.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Rest_path.Var.vars -> unit) ->
  'a handlers -> 'a handlers
val process : 'a handlers -> 'a Httpaf.Reqd.t -> unit
