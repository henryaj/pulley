require 'sinatra'
require 'net/http'
require 'json'

configure { set :server, :puma }

get '/' do
  '<html><body><center><h1>Pulley</h1></center></body></html>'
end

post '/push' do
  bc = params[:bc] # bc webhook url
  selector = params[:selector] # json path to field to display
  message = params[:message] # optional message to display

  unless message
    payload = JSON.parse(request.body.read)
    selectors = selector.split(".")
    message = payload
    selectors.each do |s|
      message = message.dig(s)
    end
  end

  uri = URI(bc)
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    # The body needs to be a JSON string, use whatever you know to parse Hash to JSON
    req.body = {content: message}.to_json
    http.request(req)
  end

  halt 200
end


