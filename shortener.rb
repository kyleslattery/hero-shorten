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

get '/' do  
  redirect 'http://kyleslattery.com'
end

# Admin section
get '/-/?' do
  @links = Link.all(:order => [:id.desc])
  erb :'links/index'
end

post '/-/create' do
  @link = Link.first_or_create(:url => params[:url])
  redirect "/-/"
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