val response_error :
  ?error:Httpaf.Status.standard -> ?text:string -> 'a Httpaf.Reqd.t -> unit
val response_ok : ?text:string -> 'a Httpaf.Reqd.t -> unit
val response_json : 'a Httpaf.Reqd.t -> Yojson.Safe.json -> unit
val request_json :
  'a Httpaf.Reqd.t ->
  ('a Httpaf.Reqd.t -> Yojson.Safe.json -> unit) -> unit
