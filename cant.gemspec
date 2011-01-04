# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cant/version"

Gem::Specification.new do |s|
  s.name        = "cant"
  s.version     = Cant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["thierry.henrio"]
  s.email       = ["thierry.henrio@gmail.com"]
  s.homepage    = "https://github.com/thierryhenrio"
  s.summary     = %q{Tiny authorization library, let you craft your own rules}
  s.description = %q{Use blocks to define what you cant do, define or reuse an existing fold function, and you are done ... As a side effect, it can be embedded where you need it}

  s.rubyforge_project = "cant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rspec', '~> 2'
  s.add_development_dependency 'wrong', '>= 0.4'
end
