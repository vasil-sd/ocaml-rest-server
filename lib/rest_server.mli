module Path = Rest_path
module Http_json = Http_json
module Api = Api
module Swagger = Swagger

val of_swagger :
  Swagger.swagger -> 'a Api.handlers -> 'a Api.handlers

val main : Async.Fd.t Api.handlers -> unit
