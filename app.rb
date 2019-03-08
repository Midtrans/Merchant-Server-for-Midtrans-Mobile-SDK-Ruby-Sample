require 'sinatra'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'

CONFIG = YAML.load(File.open('config.yml').read)
set :port, CONFIG['app_port']

post '/charge' do
  body = JSON.parse(request.body.read.to_json)
  response = chargeAPI(body)

  content_type :json
  JSON.parse(response.body).to_json
end

def chargeAPI(body)
  headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }

  base_url = CONFIG['is_production']? CONFIG['production_url'] : CONFIG['sandbox_url']
  server_key = CONFIG['is_production']? CONFIG['production_server_key'] : CONFIG['sandbox_server_key']
  uri = URI.parse(base_url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.basic_auth(server_key, '')
  request.body = body

  response = http.request(request)
end

