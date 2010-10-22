require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-migrations'
require 'dm-validations'

DataMapper.setup(:default, ENV['DATABASE_URL'])

require 'lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!

# Set the secret to the DATABASE_URL, since that's something that isn't shared
use Rack::Session::Cookie, :secret =>  ENV['DATABASE_URL']                          

def logged_in?
  return true if ENV['ADMIN_USERNAME'].nil? || ENV['ADMIN_PASSWORD'].nil?
  session['logged_in'] == 1
end

def require_log_in
  redirect '/-/login' unless logged_in?
end

get '/' do
  redirect 'http://kyleslattery.com'
end

# Admin section
get '/-/?' do  
  require_log_in
  
  @links = Link.all(:order => [:id.desc])
  erb :'links/index'
end

post '/-/create' do
  require_log_in
  
  @link = Link.first_or_create(:url => params[:url])
  redirect "/-/"
end

get '/-/login' do
  erb :login
end

get '/-/logout' do
  session['logged_in'] = nil
  redirect "/-/login"
end

post '/-/login' do
  redirect '/-/login' if params[:password] != ENV['ADMIN_PASSWORD'] ||
                         params[:username] != ENV['ADMIN_USERNAME']
                         
  session['logged_in'] = 1
  redirect '/-/'
end

get '/:slug/?' do
  if @link = Link.get_by_slug(params[:slug])
    response['Cache-Control'] = 'public, max-age=300'
    redirect @link.url, 301
  else
    status 404
    "404!"
  end
end