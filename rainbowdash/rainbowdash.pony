use "assert"
use "collections"
use "net/http"
use "net/ssl"
use "random"
use "../packages/slack"

actor RainbowDash
  let _env: Env
  let _client: SlackClient

  new create(env: Env, slackClient: SlackClient) =>
    _env = env
    _client = slackClient

  be messageReceived(msg: String) =>
    _env.out.print("RainbowDash received a message: " + msg)

    // http://www.horsepresence.com/shop/SoundsHome.html
    let sounds = [
      "http://www.horsepresence.com/shop/media/Sounds/WhinnywithBreath22.wav"
      "http://www.horsepresence.com/shop/media/Sounds/22Curiouswhinny2000.wav",
      "http://www.horsepresence.com/shop/media/Sounds/22Fillywhinnygrunt2000.wav",
      "http://www.horsepresence.com/shop/media/Sounds/22LongDblNicker2000.wav",
      "http://www.horsepresence.com/shop/media/Sounds/22Loudsqueakwhinny2000.wav"
    ]
    if msg.at("dash") then
      try
        let r = MT
        let i = r.int(sounds.size().u64()).usize()
        _env.out.print("Going to dash at: " + i.string())
        let s = sounds(i)
        _env.out.print("Going to dash: " + s)

        let name = "RainbowDash"
        SlackChannel(_client).speak(name, s)
      else
        _env.out.print("Bad dash!")
      end
    end

actor Main
  new create(env: Env) =>
    let slackClient = SlackClient(env)
    SlackListener(env, slackClient, RainbowDash(env, slackClient))
