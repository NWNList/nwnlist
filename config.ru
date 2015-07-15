require 'sinatra'
require 'savon'
require 'json'
require "rack-timeout"
require 'rack/throttle'

use Rack::Timeout
Rack::Timeout.timeout = 15

use Rack::Throttle::Minute, :max => 10

run Sinatra::Application

client = Savon.client do 
  convert_request_keys_to :none
  wsdl "http://api.mst.valhallalegends.com/NWNMasterServerAPI/NWNMasterServerAPI.svc?singleWsdl"
  # endpoint "http://api.mst.valhallalegends.com/NWNMasterServerAPI/NWNMasterServerAPI.svc/ASMX"
  # namespace "http://api.mst.valhallalegends.com/NWNMasterServerAPI"
end

puts "AVAILABLE CLIENT OPS"
puts client.operations

get '/' do
  send_file 'public/index.html'
end

get '/api' do
  send_file 'public/api.html'
end

get '/products' do
  response = client.call(:get_supported_product_list)
  if response.success?
    data = response.to_array(:get_supported_product_list_response, :get_supported_product_list_result, :string).to_json
  end
end


get '/servers/:product' do
  body = { "Product" => params['product'] }
  response = client.call(:get_online_server_list) do
    message body
  end
  if response.success?
    data = response.to_array(:get_online_server_list_response, :get_online_server_list_result).first.to_json
  end
end

get '/count/:product' do
  body = { "Product" => params['product'] }
  response = client.call(:get_online_user_count) do
    message body
  end
  if response.success?
    data = response.to_array(:get_online_user_count_response, :get_online_user_count_result).to_json
  end
end

post '/register' do
  body = { "Product" => params['product'], "ServerAddresses" => params['serverAddresses'] }
  response = client.call(:register_pending_servers) do
    message body
  end
  if response.success?
    data = response.to_array(:register_pending_servers_response, :register_pending_servers_result).to_json
  end
end
