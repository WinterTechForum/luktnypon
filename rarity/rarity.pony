use "../packages/slack"

actor Rarity
  let _client: SlackClient

  new create(client: SlackClient) =>
    _client = client

  be messageReceived(msg: String) =>
    if (msg.at("Pony say: ")) then
      SlackChannel(_client).speak("Rarity", msg.substring(10))
    end

actor EvilRarity
  let _client: SlackClient

  new create(client: SlackClient) =>
    _client = client

  be messageReceived(msg: String) =>
    if (msg.at("Pony say: ")) then
      SlackChannel(_client).speak("Evil Rarity", "Nope.")
    end

actor Main
  let _client: SlackClient

  new create(env: Env) =>
    _client = SlackClient(env)
    let rarity: Rarity = Rarity(_client)
    let evilRarity: EvilRarity = EvilRarity(_client)
    let listener: SlackListener = SlackListener(env, _client, rarity)
    listener.subscribe(evilRarity)
