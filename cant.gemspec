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
  s.summary     = %q{tiny authorization module, declarative dsl}
  s.description = %q{
    extend Cant
    -----------
        self.extend(Cant).use_backend(backend)
        
    declare rules in backend
    ------------------------
        can {|request| request.url =~ /admin/ and current_user.admin?}
        
    verify
    ------
        can? request
    }

  s.rubyforge_project = "cant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
