#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../../lib')
require 'phromo_campushallen/campus_ical'

db = MongoBookings.new
users = db.get_allusers()
ch = Campushallen.new
users.each do |u|
  puts "Fetching for #{u["username"]} ..."
  valid = ch.login(u["username"], u["password"])
  if not valid:
    puts "   Failed logon!"
    db.note_logon_failed(u["username"])
  else
    bookings = ch.bookings()
    puts "   Storing #{bookings.count} bookings"
    db.store_bookings(u["username"], ch.bookings)
  end
end
