module Tiny
  # A facade which sits in front of [HTTP::Request](https://crystal-lang.org/api/0.22.0/HTTP/Response.html),
  # providing a few helper methods. The object is passed into the block of
  # Tiny's `serve` method.
  #
  #     serve do |request, response|
  #       # Handle a GET request
  #       request.get do
  #         # Code here is run only for GET requests...
  #       end
  #
  #       # Handle a POST request
  #       request.post do
  #         # Code here is run only for POST requests...
  #       end
  #     end
  class Request
    # A enum containing valid HTTP request methods
    enum Method
      Get
      Post
      Put
      Patch
      Delete
      Options
      Head
    end

    # The server context for this request
    @context : HTTP::Server::Context

    # The param parser for this request
    @param_parser : ParamParser

    # The request parameters for this request
    getter params = {} of String => ParamParser::AllParamTypes

    # A hash of HTTP request methods mapped to block handlers
    @handlers = {} of Method => -> Nil
    getter :handlers

    # Cascade missing methods down to the server request
    macro method_missing(call)
      @context.request.{{call.name.id}}({{*call.args}})
    end

    # Create the request object
    def initialize(@context : HTTP::Server::Context)
      @param_parser = ParamParser.new @context.request

      {% for method in %w(query body json) %}
        @param_parser.{{method.id}}.each do |key, value|
          @params[key] = value
        end
      {% end %}
    end

    # Specify a block to handle GET requests
    #
    #     request.get do
    #       # Code here is run only for GET requests...
    #     end
    def get(&block)
      @handlers[Method::Get] = block
    end

    # Specify a block to handle POST requests
    #
    #     request.post do
    #       # Code here is run only for POST requests...
    #     end
    def post(&block)
      @handlers[Method::Post] = block
    end

    # Specify a block to handle PUT requests
    #
    #     request.put do
    #       # Code here is run only for PUT requests...
    #     end
    def put(&block)
      @handlers[Method::Put] = block
    end

    # Specify a block to handle PATCH requests
    #
    #     request.patch do
    #       # Code here is run only for PATCH requests...
    #     end
    def patch(&block)
      @handlers[Method::Patch] = block
    end

    # Specify a block to handle DELETE requests
    #
    #     request.delete do
    #       # Code here is run only for DELETE requests...
    #     end
    def delete(&block)
      @handlers[Method::Delete] = block
    end

    # Specify a block to handle OPTIONS requests
    #
    #     request.options do
    #       # Code here is run only for OPTIONS requests...
    #     end
    #
    # This is specified automatically by Tiny, in order to
    # implement Access Control. If you override the `options`
    # handler you will need to handle this yourself.
    def options(&block)
      @handlers[Method::Options] = block
    end

    # Specify a block to handle HEAD requests
    #
    #     request.head do
    #       # Code here is run only for HEAD requests...
    #     end
    def head(&block)
      @handlers[Method::Head] = block
    end
  end
end
