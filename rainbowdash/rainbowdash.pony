use "assert"
use "collections"
use "net/http"
use "net/ssl"
use "random"
use "../packages/slack"

actor Main
  let _env: Env
  let _client: SlackClient

  new create(env: Env) =>
    _env = env
    _client = SlackClient(_env)
    SlackListener(_env, _client, this)

  be messageReceived(msg: String) =>
    _env.out.print("Message received: " + msg)

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
        let i = r.int(sounds.size())
        _env.out.print("Going to dash at: " + i.string())
        let s = sounds(i)
        _env.out.print("Going to dash: " + s)

        let name = "RainbowDash"
        SlackChannel(_env, _client).speak(name, s)
      else
        _env.out.print("Bad dash!")
      end
    end