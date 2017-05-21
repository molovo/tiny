# tiny

A simple wrapper around [HTTP::Server](https://crystal-lang.org/api/0.22.0/HTTP/Server.html) for building CORS-enabled, multi-threaded HTTP micro-services in [Crystal].

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tiny:
    github: molovo/tiny
```

## Usage

```crystal
require "tiny"

# Create the handler for incoming requests
serve do |request, response|
  # This block will only be run on GET requests
  request.get do
    response.json({
      "message"   => "The server is up and running",
      "timestamp" => Time.now.to_s,
    })
  end

  # This block will only be run on POST requests
  request.post do
    # Do something awesome!
  end
end
```

## Contributing

1. Fork it ( https://github.com/molovo/tiny/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [@molovo](https://github.com/molovo) James Dinsdale - creator, maintainer
