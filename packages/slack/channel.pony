use "assert"
use "net/http"
use "net/ssl"

actor SlackChannel
  let _client: SlackClient
  let _channel: String

  new create(client: SlackClient) =>
    _client = client
    _channel = "C0PU3PR62" //"%23luktnypon"

  be speak(name: String, message: String) =>
    let tail = "&channel=" + _channel +
      "&username=" + name +
      "&text=" + message
    _client.send("chat.postMessage", tail, recover this~apply() end)

  be apply(request: Payload val, response: Payload val) =>
    _client.print(request, response)
