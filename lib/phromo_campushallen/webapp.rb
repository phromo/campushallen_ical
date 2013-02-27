#!/usr/bin/env ruby

require 'sinatra/base'
require "sinatra/reloader"

# TODO: Remove these LOAD_PATH alteration and learn how to do it properly
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../../lib')
require 'phromo_campushallen/campus_ical'

# @param bookings [Hash]
def bookings_to_cal(bookings)
  ical = RiCal.Calendar do |cal|
    bookings.each do |data|
      cal.event do |event|
        event.summary = data["pass"]
        event.description = data["pass"]
        event.dtstart = data["start"]
        event.dtend = data["start"] + 1*60*60
        event.location = ""
        event.url = "http://www.campushallen.se"
      end
    end
  end
end

class CampushallenWeb < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    set :base_url, ""
    set :full_url, ""
  end

  configure :production do
     set :base_url, "/campushallen"
     set :full_url, "http://www.martyn.se/campushallen"
  end

  before do
    @db = MongoBookings.new
    @full_url = settings.full_url
    @base_url = settings.base_url
  end

  get "/" do
    @login_failed = false
    erb :index
  end

  post "/makefeed" do
    username = params[:username]
    password = params[:password]

    # check that this is valid
    ch = Campushallen.new
    if not ch.login(username, password)
      # login failed
      @login_failed = true
      erb :index
    else
      # login successful
      new_feedurl = @db.store_user(username, password)

      @bookings = ch.bookings()
      @db.store_bookings(username, @bookings)

      @feedurl = "%s/feed/#{new_feedurl}" % @full_url
      erb :showlinks
    end
  end

  get "/feed/:feedid" do |feedid|
    # check if we should update feed
    u = @db.get_userforfeed(feedid)
    # TODO: Only update after x minutes
    if not u["last_update"]
      ch = Campushallen.new
      valid = ch.login(u["username"], u["password"])
      if not valid:
        @db.note_logon_failed(u["username"])
      else
        @db.store_bookings(u["username"], ch.bookings)
      end
    end

    # return bookings
    bookings = @db.get_bookings(feedid)
    ical = bookings_to_cal(bookings)
    content_type 'text/calendar'
    ical.to_s
  end

  run! if app_file == $0
end
