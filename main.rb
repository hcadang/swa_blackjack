require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

set :sessions, true

#get '/render' do # render text assignment
#  "this is for rendering text on the browser assigment!!"
#end

#get '/form' do #just following the video for form
#  erb :form
#end

#post '/myaction' do #just following the video for form
#  puts params['username']
#end

#get '/nested_template' do #render template assignment
#  erb :"/users/profile"
#end

helpers do #helper method will allow us to use this anywhere in our application
	def calculate_total(cards)
		 arr = cards.map{|e| e[0] }
  #map will give you a new array with second element

  total = 0
  arr.each do |key|
    if key == "A"
      total += 11
    elsif key.to_i == 0
      total += 10
    else
      total += key.to_i
    end
  end

  #correct for Aces
  arr.select{|e| e == "A"}.count.times do
    total -= 10 if total > 21
  end
    total
	end

  def card_image(card) #(card) is the input
    key = card[0]
    if ['J', 'Q', 'K', 'A'].include?(key) #if this array has this value then do this...
      key = case card[0]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
      end
    end
    value = case card[1]
      when 'C' then 'clubs'
      when 'S' then 'spades'
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
    end
    
  "<img src='/images/cards/#{key}_#{value}.jpg' class='card_image'>"
  #double qoutes to capture the whole string, and signle quotes for within whole string
  end
end

before do #will check to see if this statement is true with every action
	@show_hit_or_stay_buttons = true 
end

get '/' do # this action will handle the default route for port number 4567 (sinatra/reloader) or 9393 (shotgun)
	if session[:player_name] #session hash restablishes new request for that state of application, stored in cookies
		redirect '/game' #this will redirect to game.erb game itself
	else
		redirect '/new_player' #this will redirect to new_player.erb which is the form
	end
end

get '/new_player' do
	erb :new_player #this will get the new_player.erb file, the for
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

	session[:player_name] = params[:player_name] #params extracts the value of the player-name in line 4 of new_player.erb file. use session hash = params since params always reset, does not use cookies like session hash
	redirect '/game'
end

get '/game' do
	key = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
	value = ['C', 'S', 'H', 'D']
	session[:deck] = key.product(value).shuffle!
 #line 43 will shuffle the cards with suits and values

#dealing the cards
session[:player_cards] = [] #initializes to an empty array
session[:dealer_cards] = [] #initializes to an empty array
#appending (<<) cards to the dealer and player with .pop
session[:player_cards] << session[:deck].pop
session[:dealer_cards] << session[:deck].pop
session[:player_cards] << session[:deck].pop
session[:dealer_cards] << session[:deck].pop

if calculate_total(session[:player_cards]) == 21 
  @success = "Player has 21!!! Winner winner chicken dinner!"
end

 erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
		erb :game # don't want to redirect and restart the game with redirect /game you want to render game.erb
  if calculate_total(session[:player_cards]) > 21
		@error = "Sorry you busted" #@error is an instance variable from the template layout.erb, will disappear after new request
		@show_hit_or_stay_buttons = false
	end

	erb :game #don't exit so we use this to return to the state of the game
end

post '/game/player/stay' do
	@success = "Player stays at #{calculate_total(session[:player_cards])}"
	@show_hit_or_stay_buttons = false
	erb :game
end

#if calculate_total(session[:dealer_cards]) == 21
#  @error = "Dealer has blackjack!!!"
#elsif calculate_total(session[:dealer_cards]) > 21
#  @success = "Dealer has busted, Player wins!!!"
#elsif calculate_total(session[:dealer_cards]) >= 17
#  @error ="Dealer has #{calculate_total(session[:dealer_cards])}"
#else
  # dealer hits
#end

 # erb :game
#end
  


