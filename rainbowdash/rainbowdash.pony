use "assert"
use "collections"
use "net/http"
use "net/ssl"
use "../packages/slack"

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let client = SlackClient(env)
    let name = "RainbowDash"

    for i in Range(1, env.args.size()) do
      try
        client.speak(name, env.args(i))
      end
    end
