require 'cant/engine'

class User
  attr_accessor :admin
  alias_method :admin?, :admin

  extend Cant::Editable
  include Cant::Questionable
  def configuration
    self.class
  end
end
