use "assert"
use "collections"
use "json"
use "net/http"
use "net/ssl"
use "time"
use "../jsonpath"

class PollTimerNotify is TimerNotify
  let _sender: SlackListener

  new iso create(sender: SlackListener) =>
    _sender = sender

  fun ref apply(timer: Timer, count: U64): Bool =>
    _sender.poll()
    true

  fun ref cancel(timer: Timer) => None

interface SlackSubscriber
  be messageReceived(msg: String)

actor SlackListener
  let _env: Env
  let _client: SlackClient
  let _channel: String
  let _subscribers: Array[SlackSubscriber tag]

  let poll_period_seconds: U64 = 2

  new create(env: Env, client: SlackClient, subscriber: SlackSubscriber tag) =>
    _env = env
    _client = client
    _channel = "C0PU3PR62"
    _subscribers = [subscriber]

    let timers = Timers
    let listener = Timer(PollTimerNotify(this), poll_period_seconds*1_000_000_000, poll_period_seconds*1_000_000_000)
    timers(consume listener)

  be poll() =>
    let ts: I64 = Time.seconds() - poll_period_seconds.i64()
    let tail = "&channel=" + _channel + "&oldest=" + ts.string()
    _client.send(tail, recover this~handle_response() end)

  fun catStrings(seqs: Array[ByteSeq] box): String =>
    var str = ""
    for seq in seqs.values() do
      for i in Range(0, seq.size()) do
        try
          let b = seq(i)
          let bs = String.from_utf32(b.u32())
          str = str + bs
        end
      end
    end
    str

  be handle_response(request: Payload val, response: Payload val) =>
    _env.out.print("response")
    if response.status != 0 then
      let body = catStrings(response.body())
      _env.out.print("response.body: " + body)
      var message: String = ""
      let json: JsonDoc = JsonDoc
      try
        json.parse(body)

        let jp = JsonPath.obj("messages").arr(0).obj("text")
        message = jp.string(json)
      end
      if (message.size() > 0) then
        for subscriber in _subscribers.values() do
          subscriber.messageReceived(message)
        end
      end
    else
      _env.out.print("Failed: " + request.method + " " + request.url.string())
    end

  be subscribe(subscriber: SlackSubscriber tag) =>
    _subscribers.push(subscriber)

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    SlackListener(_env, SlackClient(_env), this)

  be messageReceived(msg: String) =>
    _env.out.print("Message received: " + msg)

