require 'sinatra'
require 'sinatra/reloader'
require 'csv'

configure do
  enable :sessions
  set :session_secret, "secret"
end

get '/' do
  erb :index, :locals => {accounts: getAccountList}
end

get '/full' do
  erb :full, :locals => {accounts: getAccountList}
end

get '/account' do
  erb :account, :locals => {account: selectAccount(params['name'].to_sym)}
end

get '/login' do
  erb :login
end

post '/login' do
  if checkLoginInfo
    logIn(params['username'],params['password'])
    redirect to('/admin')
  end
  redirect to('/login')
end

get '/admin' do
  erb :admin
end

# ------------------------------------------------------------------------

class Account
  attr_accessor :name
  attr_accessor :transactions

  def initialize(name, transactions)
    @name = name
    @transactions = transactions
  end

  def category_total(category)
    @transactions[category].sum.round(2)
  end

  def category_average(category)
    (self.category_total(category) / @transactions[category].length).round(2)
  end

  def balance
    balance = 0
    @transactions.each_key { |category| balance += category_total(category) }
    balance.round(2)
  end
end

# ------------------------------------------------------------------------

helpers do
  def csvData
    data = {}
    CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
      data[row["Account"].chomp.to_sym] = {}
    end
    CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
      data[row["Account"].chomp.to_sym][row["Category"].chomp.to_sym] = []
    end
    CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
      account = row["Account"].chomp.to_sym
      category = row["Category"].chomp.to_sym
      outflow = -row["Outflow"][1..-1].to_f
      inflow = row["Inflow"][1..-1].to_f
      data[account][category] << outflow + inflow
    end
    data
  end

  def getAccountList
    data = csvData; accounts = []
    data.each_key { |name| accounts << Account.new(name, data[name])}
    accounts
  end

  def selectAccount name
    data = csvData
    Account.new(name, data[name])
  end

  def readLoginFile
    accounts = []
    File.open('logins.txt', 'r').each do |line|
      accounts << line.chomp.split(', ')
    end
    accounts
  end

  def checkLoginInfo
    accounts = readLoginFile
    return accounts.include? [params['username'],params['password']]
  end

  def logIn(username,password)
    session[:user] = username
  end

  def LoggedIn
    if session[:user] != nil
      LoggedIn = true
  end

end
