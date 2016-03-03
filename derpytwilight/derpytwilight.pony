use "collections"
use "../packages/slack"
use "../packages/encoders"

actor DerpyTwilight
  var _env: Env
  var _name: String
  var _slackClient: SlackClient

  new create(env: Env) =>
    _slackClient = SlackClient(env)
    _name = try env.args(1) else "Segmentation D Fault Esq" end

    _env = env


  be messageReceived(msg: String) =>
    _env.out.print("Received message: " + msg)
    
    if msg.at("derpy") then
      _env.out.print("Found a derpy")
      _slackClient.speak("DerpyHooves", SoundEncoder.encode(msg.substring(6)))
    end

    if msg.at("sparkle") then
      _env.out.print("Found a sparkle")
      _slackClient.speak("TwilightSparkle", SoundEncoder.decode(msg.substring(8)))
    end

actor Main
  new create(env: Env) =>
    SlackListener(env, DerpyTwilight(env))