$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../../lib')

require 'rubygems'
require 'phromo_campushallen/webapp'

run CampushallenWeb
