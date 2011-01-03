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
  s.description = %q{
    include Cant
    ------------
        class User; include Cant::Embeddable; end
        
        class AuthorizationMiddleware; include Cant::Embeddable; end
        
    declare rules
    -------------
        User.cant do |action=:update, post|
          not post.user == self if Post === resource and action == :update
        end
        
        AuthorizationMiddleware.cant do |env|
          not env['user'] == env['post'].user if env.path =~ /^\posts/ and env.method == 'PUT'
        end
        
    verify
    ------
        user.cant? :update, post
        user.die_if_cant! :update, post

    control
    -------
        rescue_from Cant::AccessDenied do |error|
         flash[:error] = error.message
         redirect_to request.referer
        end
    }

  s.rubyforge_project = "cant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
