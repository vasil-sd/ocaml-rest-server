open Swagger

let obj ?description ?title ?required name properties =
  name,
  create_schema
   ~kind:`Object
   ~title
   ~description
   ~properties
   ~required
   ()

let str ?description name =
  name,
  create_schema
    ~kind:`String
    ~description
    ()

let int ?description name  =
  name,
  create_schema
    ~kind:`Integer
    ~description
    ()

let bool ?description name =
  name,
  create_schema
    ~kind:`Boolean
    ~description
    ()

let array ?description name item_type =
  name,
  create_schema
    ~kind:`Array
    ~description
    ~items:(snd item_type)
    ()

obj "qwerty"
[
  str "asdf"
; array "arr1" @@ str ""
]

let rec validate schema json =
  match schema.kind, json with
  | Some `Object, `Assoc properties
  | None, `Assoc properties ->
    present required,
    all properties match corresponding schemas
  | Some `Array, `List items 
    -> List.fold_left
         ~f:(fun a v -> a && validate schema.items v)
         true
         items
  | Some `Integer, `Int  _
  | Some `Integer, `Intlit _
  | Some `String, `String _
  | Some `Boolean, `Bool _ -> true
  | _, _ -> false
