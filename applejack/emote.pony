use "assert"
use "collections"
use "net/http"
use "net/ssl"
use "json"
use "../packages/jsonpath"
use "../packages/slack"

actor AppleJack
  let _env: Env
  let _slackClient: SlackClient
  let _client: Client

  new create(env: Env, slackClient: SlackClient) =>
    _env = env
    _slackClient = slackClient

    _env.out.print("Applejack starting...")
    let sslctx = try
      recover
        SSLContext
          .set_client_verify(true)
          .set_authority("./cacert.pem")
      end
    end

    _client = Client(consume sslctx)
    _env.out.print("Applejack started.")

  be apply(request: Payload val, response: Payload val) =>
    _env.out.print("AppleJack got response")
    if response.status != 0 then
      // TODO: aggregate as a single print
      _env.out.print(
        response.proto + " " +
        response.status.string() + " " +
        response.method)

      for (k, v) in response.headers().pairs() do
        _env.out.print(k + ": " + v)
      end

      _env.out.print("")
      _env.out.print("AppleJack's output from gliphy")

      var jsonResponse = ""
      for chunk in response.body().values() do
        _env.out.print(chunk) // chunk is a ByteSeq
        for i in Range(0, chunk.size()) do
          try
            let c = chunk(i)
            let c2 = String.from_utf32(c.u32())
            jsonResponse = jsonResponse + c2
          end
        end
      end

      _env.out.print("AppleJack's jsonResponse: " + jsonResponse)

      var eu = ""
      let json: JsonDoc = JsonDoc
      try
        json.parse(jsonResponse)
        _env.out.print("Parsed Doc")

        let jp = JsonPath.obj("data").obj("bitly_gif_url")
        eu = jp.string(json)
      end
        SlackChannel(_slackClient).speak("AppleJack", eu)
    end

  be apply2(request: Payload val, response: Payload val) =>
    None

  be messageReceived(msg: String) =>
    _env.out.print("AppleJack message received: " + msg)

    try
      if (( msg.find("happy")   > -1)) then
        getPony(msg)
      end
    end

    try
      if (( msg.find("sad")   > -1)) then
        getPony(msg)
      end
    end

  fun getPony(msg: String) =>
    try
      let s = "https://api.giphy.com/v1/gifs/translate?api_key=dc6zaTOxFJmzC&fmt=json&rating=y&s=" + msg + "%20pony"
      let url = URL.build(s)
      Fact(url.host.size() > 0)

      let req = Payload.request("GET", url, recover this~apply() end)
      _client(consume req)
    else
      _env.out.print("Malformed URL: " + msg)
    end

actor Main
  new create(env: Env) =>
    let slackClient = SlackClient(env)
    SlackListener(env, slackClient, AppleJack(env, slackClient))
