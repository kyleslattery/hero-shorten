require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'])

require 'lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do  
  redirect 'http://kyleslattery.com'
end

get '/links/new/?' do
  if params[:url]
    # just build it, don't show form
    @link = Link.first_or_create(:url => params[:url])
    'http://' + request.env['HTTP_HOST'] + '/' + @link.slug
  else
    erb :new
  end
end

post '/links/?' do
  @link = Link.first_or_create(:url => params[:link][:url])
  @link.slug
end

get '/links/?' do
  @links = Link.all
  erb :list
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