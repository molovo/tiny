require "./tiny"

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
