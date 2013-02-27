require 'rubygems'
require 'test/unit'

# $LOAD_PATH.unshift('D:/Martin/code/ruby/phromo_campushallen/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../lib')
require 'phromo_campushallen/campus_ical'

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Test getting bookings
  def test_getbookings
    ch = Campushallen.new

    # get bookings
    books = ch.login("email", "password").bookings

    # info = [{:pass=>"Bodypump 60", :when=>"on 18 jan 17:30", :info=>"C1, C2, C3, C4, Sarah B", :facility=>"LSIF Campushallen"}]
    puts books
  end

  def test_mongo
    mbooks = tomongoform(books)
    db = Mongo::Connection.new("localhost").db("campushallen")
    col = db.collection("bookings")
    col.save(mbooks[0])
    col.find("username" => "email").each { |row| puts row.inspect }
    doc = col.find_one("username" => "email")
  end
end