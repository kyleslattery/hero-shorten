require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-migrations'
require 'dm-validations'
require 'encryptor'

DataMapper.setup(:default, ENV['DATABASE_URL'])

require 'lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

def logged_in?
  return false if session['key'].nil?
  
  Encryptor.decrypt(:value => session['key'], :key => ENV['DATABASE_URL']) == request.ip
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
  session['key'] = nil
  redirect "/-/login"
end

post '/-/login' do
  redirect '/-/login' if params[:password] != ENV['ADMIN_PASSWORD'] ||
                         params[:username] != ENV['ADMIN_USERNAME']
                         
  session['key'] = Encryptor.encrypt(:value => request.ip, :key => ENV['DATABASE_URL'])
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