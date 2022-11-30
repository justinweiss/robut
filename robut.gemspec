# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "robut/version"

Gem::Specification.new do |s|
  s.name        = "robut"
  s.version     = Robut::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Justin Weiss"]
  s.email       = ["justin@uberweiss.org"]
  s.homepage    = "http://rdoc.info/github/justinweiss/robut/master/frames"
  s.summary     = %q{A simple plugin-enabled HipChat bot}
  s.description = %q{A simple plugin-enabled HipChat bot}

  s.rubyforge_project = "robut"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "xmpp4r", "~> 0.5.0"
  s.add_dependency "sinatra", ">= 1.3", "< 4.0"
  s.add_development_dependency "bundler", "~> 1.11"
end
