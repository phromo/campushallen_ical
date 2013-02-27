# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "phromo_campushallen/version"

Gem::Specification.new do |s|
  s.name        = "phromo_campushallen"
  s.version     = PhromoCampushallen::VERSION
  s.authors     = ["phromo"]
  s.email       = ["phromo@gmail.com"]
  s.homepage    = ""
  s.summary     = "Campushallen to iCalendar"
  s.description = "Logs in an publishes bookings in icalendar format"

  s.rubyforge_project = "phromo_campushallen"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "ri_cal"
  s.add_runtime_dependency "mongo"
  s.add_runtime_dependency "mechanize"
  s.add_runtime_dependency "uuid"

  s.add_development_dependency "test-unit"
end
