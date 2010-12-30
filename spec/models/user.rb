require 'cant/embeddable'

class User
  attr_accessor :admin
  alias_method :admin?, :admin

  include Cant::Embeddable
end
