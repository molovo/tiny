require "http/server"
require "json"
require "./tiny/*"

# Bootstrap the Tiny service
#
# Accepts a block with parameters `request` and `response`,
# which can be used to handle incoming requests
#
#     serve do |request, response|
#       # Your service code here...
#     end
def serve(&handler : (Tiny::Request, Tiny::Response) -> _)
  Tiny::Server.new(&handler)
end

module Tiny
end
