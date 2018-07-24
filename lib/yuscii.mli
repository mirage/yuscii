type decoder
type src = [ `Manual | `Channel of in_channel | `String of string ]
type decode = [ `Await | `End | `Uchar of Uchar.t | `Malformed of string ]

val pp_decode: Format.formatter -> decode -> unit

val src: decoder -> Bytes.t -> int -> int -> unit
val decoder: src -> decoder
val decode: decoder -> decode

val decoder_line: decoder -> int
val decoder_column: decoder -> int
val decoder_byte_count: decoder -> int
val decoder_count: decoder -> int
val decoder_src: decoder -> src

module String: sig
  type 'a folder = 'a -> int -> [ `Malformed of string | `Uchar of Uchar.t ] -> 'a

  val fold: ?off:int -> ?len:int -> 'a folder -> 'a -> string -> 'a
end
