require 'rubygems'
require 'mechanize'
require 'date'
require 'ri_cal'
require 'mongo'
require 'uuid'

class Campushallen
  def login(username, password)
    start_url = "http://bokning.campushallen.se/brp/mesh/index.action"
    @username = username
    @agent = Mechanize.new
    page = @agent.get(start_url)
    login_form = page.form('loginForm')
    login_form['username'] = username
    login_form['password'] = password
    result = @agent.submit(login_form)

    if result.body =~ /Felaktigt/
      return false
    end

    self
  end
  
  def bookings()
    booked_url = "http://bokning.campushallen.se/brp/mesh/showBookings.action"
    page = @agent.get(booked_url)
    texts = page.search("//p").collect {|x| x.text}
    if texts.any? {|x| x =~ /^Inga bokningar/}
      puts "No bookings found"
      return []
    else
      puts "Bookings found"
    end

    rows = page.search(".//table").first.search("./tr")
    rows = rows.find_all{|x| x.search("td").any?}
    
    rows.collect { |x| {
        "start" => Time.parse(x.search("td[1]").text.to_s.strip),
        "username" => @username,
        "pass" => x.search("td[2]").text.to_s.strip,
        "facility" => x.search("td[3]").text.to_s.strip,
        "info" => x.search("td[4]").text.to_s.strip }
    }
  end
end

def tomongoform(bookings, feedid)
  newbooks = bookings.clone
  newbooks.each {|x|
    x["start"] = x["start"].utc
    x["_id"] = "%s@%s" % [x["username"],  x["start"]]
    x["feedid"] = feedid
  }
  newbooks
end

class MongoBookings
  def initialize()
    @db = Mongo::Connection.new("localhost").db("campushallen")
    @col_users = @db.collection("users")
    @col_bookings = @db.collection("bookings")
  end

  # Get all users in database.
  # Returns users as [{:username=>'username', :password=>'password'}]
  #
  # @return [List]
  def get_allusers()
    puts @col_users
    @col_users.find().collect
  end

  def get_userforfeed(feedid)
    return @col_users.find_one("feedid" => feedid)
  end

  # store a new user, replace existing if it exists
  def store_user(username, password)
    doc = @col_users.find_one("_id" => username)
    if doc
      doc["password"] = password
      @col_users.save(doc)
      return doc["feedid"]
    end

    new_id = UUID.generate.split("-")[0]
    doc = {"_id" => username, "username" => username, "password" => password, "feedid" => new_id}
    @col_users.save(doc)

    return new_id
  end

  def note_logon_failed(username)
    user = @col_users.find_one({"username" => username})
    if user["logon_failed"]
      puts "   Failed logon attempts: %s" % user["logon_failed"]
      if user["logon_failed"] > 5
        puts "   Removing user after 7th failed attempts"
        @col_users.remove(user)
        return
      end

      user["logon_failed"] += 1
    else
      user["logon_failed"] = 1
    end

    @col_users.save(user)
  end

  # Get all bookings for a given feedid
  def get_bookings(feedid)
    @col_bookings.find({"feedid" => feedid})
  end

  def store_bookings(username, bookings)
    user = @col_users.find_one({"username" => username})
    tomongoform(bookings, user["feedid"]).each do |x|
      @col_bookings.save(x)
    end
  end
end