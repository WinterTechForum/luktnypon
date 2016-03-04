use "../applejack"
use "../rainbowdash"
use "../rarity"
use "../derpytwilight"
use "../packages/slack"

actor Main
  let _env: Env
  let _client: SlackClient

  new create(env: Env) =>
    _env = env
    _client = SlackClient(env)

    // Apple Jack
    let appleJack: AppleJack = AppleJack(env)
    let listener: SlackListener = SlackListener(env, appleJack)

    // Derpy Twilight
    let derpyTwilight: DerpyTwilight = DerpyTwilight(env)
    listener.subscribe(derpyTwilight)

    // Evil Rarity
    let evilRarity: EvilRarity = EvilRarity(_client)
    listener.subscribe(evilRarity)

    // Rarity
    let rarity: Rarity = Rarity(_client)
    listener.subscribe(rarity)

  be messageReceived(msg: String) =>
    _env.out.print("Message received: " + msg)
