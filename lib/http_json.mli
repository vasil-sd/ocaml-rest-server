val response_error :
  ?error:Httpaf.Status.standard -> ?text:string -> 'a Httpaf.Reqd.t -> unit
val response_ok : 'a Httpaf.Reqd.t -> unit
val http_send_json_response : 'a Httpaf.Reqd.t -> Yojson.Safe.json -> unit
val http_receive_json_request :
  'a Httpaf.Reqd.t ->
  Httpaf.Request.t ->
  ('a Httpaf.Reqd.t -> Httpaf.Request.t -> Yojson.Safe.json -> unit) -> unit
