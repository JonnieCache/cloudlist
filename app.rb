require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'haml'
require 'yajl/json_gem'

def glean(track, key)
  result = track.css(key)
  text = result[0].text
  return text
end

def user_from_url(url)
  r = /soundcloud\.com\/([^\/]*).*/
  res = r.match(url)
  res ? res[1] : url
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
    content_type 'application/json'
    return data
  rescue Exception => e
    response.status = e.class.to_s != 'OpenURI::HTTPError' ? 500 : e.io.status[0]
    'soundcloud not happy. she say: '+e.message
  end
end

def get_playlist(user)
  url = "http://api.soundcloud.com/users/#{user}/tracks?filter=streamable"

  begin
    doc = Nokogiri::XML(open(url))
    tracks = doc.root.xpath('//track')

    m3u = ["#EXTM3U"] + tracks.collect do |t|
      line = '#EXTINF:'

      line += (glean(t, 'duration').to_i/1000).to_s+','
      line += glean(t, 'username')
      line += ' - '
      line += glean(t, 'title')
      line2 = glean(t, 'stream-url')
      [line, line2].join("\n")+"\n"
    end
    
    if(m3u == ["#EXTM3U"])
      response.status = 404
      'no tracks'
    else
      content_type 'audio/x-mpegurl'
      m3u.join("\n")
    end
    
  rescue Exception => e
    response.status = e.class.to_s != 'OpenURI::HTTPError' ? 500 : e.io.status[0]
    'soundcloud not happy. she say: '+e.message
  end
end

get '/' do
  haml :root
end

get '/user.json' do
  user = user_from_url(params[:url])
  get_user(user).to_json
end

get '/playlist.m3u' do
  user = user_from_url(params[:url])
  redirect "/#{user}.m3u"
end

get '/:user.m3u' do
  get_playlist(params[:user])
end

get '/style.css' do
  response.header['Content-Type'] = 'text/css; charset=utf-8'
  sass :style
end
