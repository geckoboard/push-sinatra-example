require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'

enable :sessions

get '/' do
  if session[:data].nil? then
    session[:data] = {}
  end
  
  erb :index
end

post '/push' do
  # take the three parameters and push in the correct format to GB
  url = "https://push.geckoboard.com/v1/send/#{params[:widget_key]}"
  
  data = {:item => [{:text=>params[:text], :type => 0}]}
  payload = {:api_key => params[:api_key], :data => data}
  
  # fire off the request
  begin
    response = RestClient.post url, payload.to_json, :content_type => "application/json"
    session[:message] = "Successfully updated widget!"

  rescue RestClient::Exception => e
    # oops, got an error. Try to parse it and display to the user
    # puts e
    puts "got an error"
    puts e.message
    body = JSON.parse(e.response.body)
    session[:error] = body["error"]
    session[:data] = {
      :api_key => params[:api_key],
      :text => params[:text],
      :widget_key => params[:widget_key]
    }
  end
  
  redirect '/'
end