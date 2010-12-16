require 'cant/engine'
require 'forwardable'

module Cant
  module Dsl
    extend Forwardable
    def_delegators :cant, :can, :can?
    def cant
      @cant ||= Cant::Engine.new
    end
  end
end
