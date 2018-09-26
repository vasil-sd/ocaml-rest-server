# Rest_server

It is a simple framework for developing RESTfull JSON-communicating web-applications.
Based on Http/af and Yojson.

## Installation

```bash
git clone https://github.com/vasil-sd/ocaml-rest-server.git
opam pin add ocaml-rest-server
```

## Usage

```ocaml
open Core

let items : (string * Yojson.Safe.json) list ref = ref []
let get_item name = Core.List.find ~f:(fun (n,_) -> name = n) !items
let del_item name = items := Core.List.filter ~f:(fun (n,_) -> name <> n ) !items
let add_item name json = items := (name, json) :: !items

module RA = Rest_server.Api

let get_items {RA.response_json;_} =
  `List (List.map ~f:(fun (n,_) -> `String n) !items)
  |> response_json

let get_item {RA.get_path_var; response_json; response_error; _} =
  let name = get_path_var "name" in
  match name with
  | None -> response_error ~text:"Parameter name is not defined!" ()
  | Some name ->
    match get_item name with
    | None ->
        response_error ~error:`Not_found
          ~text:("Rule '" ^ name ^ "' is not found!")
          ()
    | Some (_, json) ->
        response_json json

let put_item {RA.get_path_var; response_error; response_ok;_} json =
 let name = get_path_var "name" in
 match name with
 | None -> response_error ~text:"Parameter name is not defined!" ()
 | Some name -> add_item name json; response_ok ()

let del_item {RA.get_path_var; response_ok; response_error;_} =
  let name = get_path_var "name" in
  match name with
  | None -> response_error ~text:"Parameter name is not defined!" ()
  | Some name -> del_item name ; response_ok ()

let () =
  let open Rest_server in
  let open Api in
  empty
  |> get "/rules" (RA.Without_request get_items)
  |> post "/rules/{name}" (RA.With_request put_item)
  |> get "/rules/{name}" (RA.Without_request get_item)
  |> delete "/rules/{name}" (RA.Without_request del_item)
  |> main
```

## License

BSD3, see LICENSE file for its text.
