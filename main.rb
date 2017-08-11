require "sinatra"
require "sinatra/reloader"
require_relative "./csv.rb"

get "/" do 
 erb(:index)
end

get "/fullrpt" do
  accounts = run_csv_processor
  erb(:fullrpt, :locals => {:accounts => accounts})
end

get "/account" do
  accounts = run_csv_processor
  name = params[:name]
	erb(:account, :locals => {info: accounts[name], name: name}) 
end


