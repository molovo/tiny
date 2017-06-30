require "crayon"
require "dotenv"
require "herd"

module Tiny
  class Server
    # Configuration values for Tiny's server
    @@config = {
      "HOSTNAME"     => "127.0.0.1",
      "PORT"         => 3000,
      "ALLOW_ORIGIN" => "*",
      "THREADS"      => 1,
    }

    # The underlying HTTP::Server instance
    @server : HTTP::Server?

    # Get the current config
    def self.config
      @@config
    end

    # Create the Tiny server instance
    def initialize(&handler : (Request, Response) -> _)
      @@config = @@config.merge Dotenv.load

      cluster = Herd::Cluster.new @@config["THREADS"].to_i32
      cluster.execute do
        # Create a new server instance
        @server = HTTP::Server.new(@@config["HOSTNAME"].to_s, @@config["PORT"].to_i32) do |context|
          # Set up the request and response
          request = Request.new context
          response = Response.new context

          # Run the handler
          handler.call request, response

          setup_access_control request, response

          next route_request request, response
        end

        listen
      end
    end

    # Set up access control for the request
    private def setup_access_control(request : Request, response : Response)
      # Set the `Access-Control-Allow-Origin` header
      response.allow_origin @@config["ALLOW_ORIGIN"].to_s

      # Find the allowed methods
      allowed_methods = [] of Request::Method
      Request::Method.values.each do |method|
        if request.handlers.has_key? method
          allowed_methods << method
        end
      end

      # Set the `Access-Control-Request-Method` header
      response.request_methods allowed_methods.map { |method|
        method.to_s.upcase
      }
    end

    # Pass the request to the correct handler
    private def route_request(request : Request, response : Response)
      # Get the request method
      method = Request::Method.parse? request.method

      unless method.nil?
        # Print an empty response for OPTIONS requests
        if method.options?
          return response.send 200
        end

        # If the request method is allowed, call its handler
        if request.handlers.has_key? method
          return handle request.handlers[method], request, response
        end
      end

      response.error 405, "Method Not Allowed"
    end

    # Handle an incoming request
    private def handle(handler, request : Request, response : Response)
      output = handler.call
    rescue ex
      # Handle uncaught exceptions, and return an error message
      message = ex.message
      message ||= "Sorry, an error occurred"

      response.error message
    end

    # Start the server and print a message to stdout
    private def listen
      crayon = Crayon::Text.new

      box = Crayon::Box.new [
        crayon.yellow.render("Tiny is listening..."),
        "",
        "URL: http://#{@@config["HOSTNAME"]}:#{@@config["PORT"]}",
      ]

      box.set_border_color Crayon::Color::Yellow
      box.set_padding 2, 1
      box.set_margin 2, 1
      puts box.render

      server = @server
      unless server.nil?
        server.listen true
      end
    end
  end
end
