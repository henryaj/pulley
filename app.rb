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
      if message.is_a?(Array)
        message = message.first
      end
      message = message.dig(s)
    end
    message.gsub("\n","<br>")
  end

  p message

  return 500 unless message

  uri = URI(bc)
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    req = Net::HTTP::Post.new(uri)
    req.body = "content=#{message}"
    http.request(req)
  end

  halt 200
end


