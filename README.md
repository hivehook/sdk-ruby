# hivehook (Ruby)

Official Ruby client for [Hivehook](https://hivehook.com), webhook infrastructure for modern teams (inbound and outbound).

Latest release: **0.1.1** on [RubyGems](https://rubygems.org/gems/hivehook).

## Install

```bash
gem install hivehook
```

Or in your `Gemfile`:

```ruby
gem "hivehook"
```

## Quick start

```ruby
require "hivehook"

client = Hivehook::Client.new(
  base_url: "http://localhost:8080",
  api_key: ENV.fetch("HIVEHOOK_API_KEY"),
)

source = client.sources.create(
  "name" => "Stripe production",
  "slug" => "stripe-prod",
  "providerType" => "stripe",
  "verifyConfig" => { "secret" => "whsec_..." },
)

puts "created source #{source['id']}. POST webhooks to /ingest/#{source['slug']}"
```

## Webhook signature verification

```ruby
require "hivehook/webhook"

signature = request.headers["X-Hivehook-Signature"]
timestamp = request.headers["X-Hivehook-Timestamp"].to_i
ok = Hivehook::Webhook.verify(body, "your-signing-secret", signature, timestamp, 300)
```

## Documentation

See the full reference at [hivehook.com/docs](https://hivehook.com/docs).

## License

MIT. See [LICENSE](LICENSE).
