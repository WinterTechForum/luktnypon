primitive Neigh
  fun apply(): String => "Neigh"
  fun ord(): U8 => 0
primitive Whinny
  fun apply(): String => "Whinny"
  fun ord(): U8 => 1
primitive Chuff
  fun apply(): String => "Chuff"
  fun ord(): U8 => 2
primitive Groan
  fun apply(): String => "Groan"
  fun ord(): U8 => 3
primitive Yoohoo
  fun apply(): String => "Yoohoo"
  fun ord(): U8 => 4
primitive Snort
  fun apply(): String => "Snort"
  fun ord(): U8 => 5
primitive Blow
  fun apply(): String => "Blow"
  fun ord(): U8 => 6
primitive Sigh
  fun apply(): String => "Sigh"
  fun ord(): U8 => 7

type NeighEntry is (Neigh | Whinny | Chuff | Groan | Yoohoo | Snort | Blow | Sigh)

primitive NeighEntryList
  fun tag apply(): Array[NeighEntry] =>
    [Neigh, Whinny, Chuff, Groan, Yoohoo, Snort, Blow, Sigh]
  fun tag find(v: String): NeighEntry? =>
    for n in NeighEntryList().values() do
      if v == n() then
        return n
      end
    end
    error

actor Main
  let _env: Env
  new create(env: Env) =>
    _env = env
    try
      let command: String = _env.args(1)
      let input: String = _env.args(2)
      match command
        | "dec" => decode(input)
        | "enc" => encode(input)
      else
        usage()
      end
    else
      usage()
    end

  fun usage() =>
    try
      _env.out.print("Usage "+_env.args(0)+" (dec|enc) string")
      _env.exitcode(2)
    else
      _env.out.print("Could not access arguments!")
    end

  fun encode(input: String) =>
      _env.out.print("Encoding: "+input)
      let r = StringEncoder
      NeighEncoder.encode(input, r)
      r.display(_env)
      _env.exitcode(0)

  fun decode(input: String) =>
      _env.out.print("Decoding: "+input)
      let r = StringDecoder
      NeighEncoder.decode(input, r)
      r.display(_env)
      _env.exitcode(0)

interface EncoderResult
  be write(b: U8)

actor StringEncoder
  var result: String ref = recover String end

  new create() => None
  fun ref append(h: String) => result.append(h)

  be write(b: U8) =>
    try
      append(NeighEntryList()(b.u64())())
      append(" ")
    end

  be display(env: Env) => env.out.print("Result: "+result)

actor StringDecoder
  var result: Array[U8] ref = recover Array[U8] end

  new create() => None

  fun ref append(b: U8) => result.push(b)

  fun ref getResult(): String =>
    var res = String(result.size())
    var idx:I64 = 0
    for c in result.values() do
      res.insert_byte(idx,c)
      idx = idx + 1
    end
    res.string()

  be write(b: U8) => append(b)
  be display(env: Env) => env.out.print("Result: "+getResult())

class FilterBin
  let offset: U8
  let mask: U8
  new create(o:U8, m:U8) =>
    offset = o
    mask = m

primitive NeighEncoder
  fun encode(input: String, out: EncoderResult tag) =>
    let bins: Array[FilterBin] = [
      FilterBin(0,7),
      FilterBin(3,7),
      FilterBin(6,3)
    ]
    for i in input.values() do
      for b in bins.values() do
        let by:U8 = (i and (b.mask << b.offset)) >> b.offset
        out.write(by)
      end
    end

  fun decode(input: String, out: EncoderResult tag) =>
    let bins: Array[FilterBin] = [
      FilterBin(0,7),
      FilterBin(3,7),
      FilterBin(6,3)
    ]
    let listOfNeigh: Array[String] box = input.split("! \\")
    var b: U8 = 0
    var step: U64 = 0
    for n in listOfNeigh.values() do
      if n.size() != 0 then
        try
          let c = NeighEntryList.find(n).ord()
          b = b or (c << bins(step).offset)
          step = step + 1
        else
          for er in ("ERROR"+n).values() do
            out.write(er)
          end
        end
        if (step == bins.size()) then
          // We have a full U8 in b
          out.write(b)
          b = 0
          step = 0
        end
      end
    end

