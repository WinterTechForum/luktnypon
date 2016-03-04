use "collections"
use "../packages/slack"
use "../packages/encoders"

actor DerpyTwilight
  var _env: Env
  var _name: String
  var _slackClient: SlackClient

  new create(env: Env, slackClient: SlackClient) =>
    _slackClient = slackClient
    _name = try env.args(1) else "Segmentation D Fault Esq" end

    _env = env


  be messageReceived(msg: String) =>
    _env.out.print("Received message: " + msg)
    
    if msg.at("derpy") then
      _env.out.print("Found a derpy")
      SlackChannel(_slackClient).speak("DerpyHooves", SoundEncoder.encode(msg.substring(6)))
    end

    if msg.at("sparkle") then
      _env.out.print("Found a sparkle")
      SlackChannel(_slackClient).speak("TwilightSparkle", SoundEncoder.decode(msg.substring(8)))
    end

actor Main
  new create(env: Env) =>
    let slackClient = SlackClient(env)
    SlackListener(env, slackClient, DerpyTwilight(env, slackClient))
