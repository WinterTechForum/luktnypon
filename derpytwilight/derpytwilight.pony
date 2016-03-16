use "collections"
use "../packages/slack"
use "../packages/encoders"

actor DerpyTwilight
  let _env: Env
  let _slackClient: SlackClient
  let _name: String

  new create(env: Env, slackClient: SlackClient) =>
    _env = env
    _slackClient = slackClient
    _name = try env.args(1) else "Segmentation D Fault Esq" end

  be messageReceived(msg: String) =>
    _env.out.print("Derpy Twilight received message: " + msg)

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
