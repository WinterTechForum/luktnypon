use "../applejack"
use "../rainbowdash"
use "../rarity"
use "../derpytwilight"
use "../packages/slack"

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let client = SlackClient(env)

    // Apple Jack
    let appleJack: AppleJack = AppleJack(env, client)
    let listener: SlackListener = SlackListener(env, client, appleJack)

    // Derpy Twilight
    let derpyTwilight: DerpyTwilight = DerpyTwilight(env, client)
    listener.subscribe(derpyTwilight)

    // Evil Rarity
    let evilRarity: EvilRarity = EvilRarity(client)
    listener.subscribe(evilRarity)

    // Rainbow Dash
    let rainbowDash: RainbowDash = RainbowDash(env, client)
    listener.subscribe(rainbowDash)

    // Rarity
    let rarity: Rarity = Rarity(client)
    listener.subscribe(rarity)

  be messageReceived(msg: String) =>
    _env.out.print("Message received: " + msg)
