require "./spec_helper"

describe Tiny do
  hostname = Tiny::Server.config["HOSTNAME"].to_s
  port = Tiny::Server.config["PORT"].to_i32

  it "listens for GET requests" do
    spawn do
      serve do |request, response|
        request.get do
          response.send "It Works"
        end
      end
    end

    sleep 1

    it "responds with 200 for GET request" do
      response = HTTP::Client.get "http://#{hostname}:#{port}"
      response.status_code.should eq(200)
      response.body.should eq("It Works")
    end

    it "response with 405 for POST request" do
      response = HTTP::Client.post "http://#{hostname}:#{port}"
      response.status_code.should eq(405)
      response.body.should eq("{\"error\":\"Method Not Allowed\"}")
    end
  end

  it "listens for POST requests" do
    Tiny::Server.config["PORT"] = port += 1
    spawn do
      serve do |request, response|
        request.post do
          response.send "It Works"
        end
      end
    end

    sleep 1

    it "responds with 200 for POST request" do
      response = HTTP::Client.post "http://#{hostname}:#{port}"
      response.status_code.should eq(200)
      response.body.should eq("It Works")
    end

    it "response with 405 for GET request" do
      response = HTTP::Client.get "http://#{hostname}:#{port}"
      response.status_code.should eq(405)
      response.body.should eq("{\"error\":\"Method Not Allowed\"}")
    end
  end

  it "returns a JSON response" do
    Tiny::Server.config["PORT"] = port += 1
    spawn do
      serve do |request, response|
        request.get do
          response.json({
            "success" => true,
          })
        end
      end
    end

    sleep 1

    response = HTTP::Client.get "http://#{hostname}:#{port}"
    response.status_code.should eq(200)
    response.headers["Content-Type"].should eq("application/json")
    response.body.should eq("{\"success\":true}")
  end

  it "returns custom status code" do
    Tiny::Server.config["PORT"] = port += 1
    spawn do
      serve do |request, response|
        request.get do
          response.send 500, "It's Broken :("
        end

        request.post do
          response.send 403, "Forbidden"
        end
      end
    end

    sleep 1

    it "responds with 500 for GET request" do
      response = HTTP::Client.get "http://#{hostname}:#{port}"
      response.status_code.should eq(500)
      response.body.should eq("It's Broken :(")
    end

    it "response with 403 for POST request" do
      response = HTTP::Client.post "http://#{hostname}:#{port}"
      response.status_code.should eq(403)
      response.body.should eq("Forbidden")
    end
  end

  it "handles uncaught errors" do
    Tiny::Server.config["PORT"] = port += 1
    spawn do
      serve do |request, response|
        request.get do
          raise "Something happened"
        end
      end
    end

    sleep 1

    it "responds with 500 for GET request" do
      response = HTTP::Client.get "http://#{hostname}:#{port}"
      response.status_code.should eq(500)
      response.body.should eq("{\"error\":\"Something happened\"}")
    end
  end
end
