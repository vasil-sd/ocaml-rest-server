open Core

module Var = struct
  type t = {name: string; value: string}

  type vars = t Core.List.t

  let get vs vname =
    match
      List.find ~f:(fun {name; _} -> vname = name) vs
    with
    | None -> None
    | Some {value; _} -> Some value
end

type elt = Str of string | Var of string

type t = elt Core.List.t

let split_path_string p =
  String.split ~on:'/' p
  |> List.filter ~f:(fun s -> not @@ String.is_empty s)

let in_curl_braces s =
  let len = String.length s in
  if
    len >= 2
    && String.unsafe_get s 0 = '{'
    && String.unsafe_get s (len - 1) = '}'
  then Some String.(drop_prefix (drop_suffix s 1) 1)
  else None

let from_string p =
  p |> split_path_string
  |> List.map ~f:(fun s ->
         match in_curl_braces s with
         | Some s -> Var s
         | None -> Str s )

let append p1 p2 = Core.List.append p1 p2

let match_path path path_pattern =
  let rec matcher vars p1 p2 =
    match (p1, p2) with
    | [], [] -> Some vars
    | [], _ :: _ -> None
    | _ :: _, [] -> None
    | h1 :: t1, h2 :: t2 ->
      match (h1, h2) with
      | Str s1, Str s2 when s1 = s2 -> matcher vars t1 t2
      | Var _, Var _ -> matcher vars t1 t2
      | Str value, Var name ->
          matcher ({Var.name; value} :: vars) t1 t2
      | _, _ -> None
  in
  matcher [] path path_pattern
