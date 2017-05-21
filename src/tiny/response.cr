module Tiny
  # A facade which sits in front of [HTTP::Server::Response](https://crystal-lang.org/api/0.22.0/HTTP/Server/Response.html),
  # providing a few helper methods. The object is passed into the block of
  # Tiny's `serve` method.
  #
  #     serve do |request, response|
  #       # Return text to the client
  #       response.send "Unicorns!"
  #
  #       # Return text with a specific status code
  #       response.send 500, "An error occurred"
  #
  #       # Return a JSON object
  #       response.json {
  #         "testing" => "test"
  #       }
  #     end
  class Response
    @context : HTTP::Server::Context

    # Cascade missing methods down to the server response
    macro method_missing(call)
      @context.response.{{call.name.id}}({{*call.args}})
    end

    # Create the response object
    def initialize(@context : HTTP::Server::Context)
    end

    # Send a JSON response with a 200 status code
    #
    #     response.json {
    #       "rainbows": "unicorns"
    #     }
    def json(object : JSON::Type)
      @context.response.content_type = "application/json;charset=utf-8"
      send object.to_json
    end

    # Send a JSON response with a specific status code
    #
    #     response.json 500, {
    #       "error": "Something happened"
    #     }
    def json(code : Int32, object : JSON::Type)
      @context.response.content_type = "application/json;charset=utf-8"
      send code, object.to_json
    end

    # Send a response with a 200 status code
    #
    #     response.send "Tada!"
    #
    # Multi-line responses can be sent by passing multiple strings
    #
    #     response.send
    #       "First Line",
    #       "Second Line",
    #       "Third Line"
    def send(*message : String)
      send 200, message.join("\n")
    end

    # Send a response with a 200 status code
    #
    #     response.send 403, "You're not allowed to do that"
    #
    # Multi-line responses can be sent by passing multiple strings
    #
    #     response.send 403,
    #       "Oh, crumbs!",
    #       "You're not allowed to do that"
    def send(code : Int32, *message : String)
      @context.response.status_code = code
      @context.response.print message.join("\n")
    end

    # Send an empty response with a specific status code
    #
    #     response.send 200
    def send(code : Int32)
      send code, ""
    end

    # Send an error response with a 500 status code
    #
    #     response.error "Something happened"
    def error(message : String)
      error 500, message
    end

    # Send an error response with a specific status code
    #
    #     response.error 403, "Something happened"
    def error(code : Int32, message : String)
      json code, {
        "error" => message,
      }
    end

    # Set the `Access-Control-Allow-Origin` header
    #
    #     response.allow_origin "example.com"
    def allow_origin(hostname : String?)
      hostname ||= "*"
      @context.response.headers["Access-Control-Allow-Origin"] = hostname
    end

    # Set the `Access-Control-Request-Method` header
    #
    #     response.request_methods ["GET", "POST"]
    def request_methods(methods : Array(String))
      @context.response.headers["Access-Control-Request-Method"] = methods.join(",")
    end
  end
end
