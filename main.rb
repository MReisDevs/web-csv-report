require "sinatra"
require "sinatra/reloader"
require "csv"
require_relative "./csv.rb"

configure do
  enable :sessions
  set :session_secret, "secret"
end

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

get '/login' do
  erb :login
end

post '/login' do
    if checkLogins
    login(params['username'],params['password'])
  redirect to('/admin')
  else
  redirect to('/login')
  end
end

get '/admin' do
  if logged_in?
    erb :admin
  else 
    redirect to('/login')
  end
end

post '/admin' do
  if params[:transtype] == "in"
    writetransaction(params[:name], params[:date], params[:payee], params[:category], "$0.00", params[:amount])
  elsif params[:transtype] == "out"
    writetransaction(params[:name], params[:date], params[:payee], params[:category], params[:amount], "$0.00")
  end
  redirect to('/admin')
end



helpers do

	def accessLogins
    logins = []
    File.open('logins.txt', 'r').each do |line|
      logins << line.chomp.split(', ')
    end
    logins
  end

  def checkLogins
    users = accessLogins
    return users.include? [params['username'],params['password']]
  end

  def login(username, password)
    session[:user] = username
  end

    def writetransaction(account, date, payee, category, outflow, inflow)
    File.open('./accounts.csv', 'a'){|f| f <<"\n#{account},#{date},#{payee},#{category},#{outflow},#{inflow}"}
    end
  
  def logged_in?
    session[:user] != nil
  end
end
