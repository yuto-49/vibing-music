require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'json'
require 'net/http'
require 'sinatra/activerecord'
require './models'
require 'open-uri'
require 'json'
require 'net/http'
require 'rspotify'
require 'google/apis/youtube_v3'
require 'active_support/all'

GOOGLE_API_KEY="AIzaSyAsrX84Lhr52TOopMjcob3c1tavy7QmrDg"

RSpotify.authenticate("07db1465e7af44de95e9e6d680faa67b", "2910437b0a6a498994dbbb60dbaa8912")

  def find_videos(youtubekeyword)
    service = Google::Apis::YoutubeV3::YouTubeService.new
    service.key = GOOGLE_API_KEY

    next_page_token = nil
    opt = {
      q: youtubekeyword,
      type: 'video',
      max_results: 1,
      page_token: next_page_token,
    }
    service.list_searches(:snippet, opt)
  end




enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end


get '/' do
  erb :frontpage, :layout =>  nil
end

get '/index' do
  @rooms = Room.all
  erb :index
end

get '/signup' do
   erb :sign_up
end

post '/signup' do
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
 if user.persisted?
  session[:user] = user.id
 end
 redirect '/'
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user]= nil
  redirect '/'
end



post '/room/start' do

  if session[:user].nil?
    redirect '/'
  end

  room = Room.create(
    user_id: params[:id],
    title: params[:title],
    youtubekeyword: params[:youtubekeyword]
  )
      @youtube_data = find_videos(params[:youtubekeyword])

    erb :room_admin
end

get '/room/admin/:id' do
    room = Room.find_by(id: params[:id])

    # artist = room.artist
    # artists = RSpotify::Artist.search(artist)
    # @artist = artists.first
    # @albums = @artist.albums
    # am = @albums.first
    # @tracks = am.tracks
    # searchplaylists = RSpotify::Playlist.search(params[:playlist])
    # @playlist = searchplaylists.first
   @youtube_data = find_videos(Room.find(params[:id]).youtubekeyword)

    erb :room_admin
end


get '/room/create' do
  erb :room_create
end

post '/room/party/:id' do
  current_user.parties.create(
    room_id: params[:id]
  )
  @id = params[:id]
  redirect "/room/admin/#{@id}"
end
