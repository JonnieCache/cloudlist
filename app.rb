require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'haml'
require 'yajl/json_gem'

set :environment, :development

def glean(track, key)
  result = track.css(key)
  text = result[0].text
  return text
end

def get_user(user)
  url = "http://api.soundcloud.com/users/#{user}"
  data = {};
  begin
    doc = Nokogiri::XML(open(url))
    e = doc.root
    data = {
      :username => glean(e, 'username'),
      :full_name => glean(e, 'full-name'),
      :track_count => glean(e, 'track-count'),
      :avatar_url => glean(e, 'avatar-url'),
      :permalink => glean(e, 'permalink')
    }
    response.header['content-type'] = 'application/json'
    return data
  rescue OpenURI::HTTPError => e
    response.status = e.io.status[0]
    'soundcloud not happy. she say: '+e.message
  end
end

def get_playlist(user)
  url = "http://api.soundcloud.com/users/#{user}/tracks?filter=streamable"

  begin
    doc = Nokogiri::XML(open(url))
    tracks = doc.root.children.xpath('//track')

    m3u = ["#EXTM3U"] + tracks.collect do |t|
      line = '#EXTINF:'

      line += (glean(t, 'duration').to_i/1000).to_s+','
      line += glean(t, 'username')
      line += ' - '
      line += glean(t, 'title')
      line2 = glean(t, 'stream-url')
      [line, line2].join("\n")+"\n"
    end
    response.header['content-type'] = 'audio/x-mpegurl'
    
    body = m3u.join("\n")
    
  rescue OpenURI::HTTPError => e
    body = 'soundcloud not happy. she say: '+e.message
  end
end

get '/' do
  haml :root
end

get '/generate' do
  redirect '/'+params[:username]+'.m3u'
end

get '/:user.json' do
  get_user(params[:user]).to_json
end

get '/:user.m3u' do
  get_playlist(params[:user])
end

get '/style.css' do
  response.header['Content-Type'] = 'text/css; charset=utf-8'
  sass :style
end
