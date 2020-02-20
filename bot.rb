require "sinatra/base"

class WhatsAppBot < Sinatra::Base
  use Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/bot'

  post '/bot' do
    body = params["Body"].downcase
    response = Twilio::TwiML::MessagingResponse.new
    response.message do |message|
      if body.include?("dog")
        message.body(Dog.fact)
        message.media(Dog.picture)
      elsif body.include?("cat")
        message.body(Cat.fact)
        message.media(Cat.picture)
      else !(body.include?("dog") || body.include?("cat"))
        message.body("I only know about dogs or cats, sorry!")
      end
    end
    content_type "text/xml"
    response.to_xml
  end
end

module Dog
  def self.fact
    response = HTTP.get("https://dog-api.kinduff.com/api/facts")
    JSON.parse(response.to_s)["facts"].first
  end

  def self.picture
    response = HTTP.get("https://dog.ceo/api/breeds/image/random")
    JSON.parse(response.to_s)["message"]
  end
end

module Cat
  def self.fact
    response = HTTP.get("https://catfact.ninja/fact")
    JSON.parse(response.to_s)["fact"]
  end

  def self.picture
    response = HTTP.get("https://api.thecatapi.com/v1/images/search")
    JSON.parse(response.to_s).first["url"]
  end
end
