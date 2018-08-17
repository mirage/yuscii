let conv7 ~f ~t s =
  let tp = Bytes.create 128 in
  let rs = Buffer.create 128 in
  let f = match f with `UTF_7 -> "-f7" | `UTF_8 -> "-f8" in
  let t = match t with `UTF_7 -> "-t7" | `UTF_8 -> "-t8" in
  let ic, oc, ec = Unix.open_process_full "" [| "conv7"; f; t |] in
    output_string oc s
  ; close_out oc
  ; let rec go () = match input ic tp 0 128 with
      | ln ->
        Buffer.add_subbytes rs tp 0 ln
      ; go ()
      | exception Not_found -> Buffer.contents rs in
    let rs = go () in
    let _  = Unix.close_process_full (ic, oc, ec) in
    rs

let generator = conv7 ~f:`UTF_8 ~t:`UTF_7
let oracle = conv7 ~f:`UTF_7 ~t:`UTF_8

let test expect s () =
  let buf = Buffer.create 128 in

  let decoder = Yuscii.decoder (`String s) in
  let encoder = Uutf.encoder `UTF_8 (`Buffer buf) in

  let rec go () = match Yuscii.decode decoder with
    | `Await -> assert false
    | `End ->
      let[@warning "-8"] `Ok : [ `Ok | `Partial ] = Uutf.encode encoder `End in
      Buffer.contents buf
    | `Malformed _ as m -> Fmt.invalid_arg "Got an malformed input: %a." Yuscii.pp_decode m
    | `Uchar _ as v -> match Uutf.encode encoder v with
      | `Ok -> go ()
      | `Partial -> assert false in

  let result = go () in
  Alcotest.(check string) expect expect result

let tests =
  [ "1 + 2 = 3;", "1 +- 2 +AD0 3;"
  ; "~~+", "+AH4AfgAr-"
  ; "~-", "+AH4--" ]
  |> List.map (fun (expect, s) -> expect, `Quick, test expect s)

let () =
  Alcotest.run "yuscii"
    [ "sample", tests ]
