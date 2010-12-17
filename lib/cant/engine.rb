module Cant
  class << self
    attr_writer :backend
    def backend
      @backend ||= nil
    end
  end 

  class Engine
    attr_accessor :backend
    attr_writer :raise
    
    def initialize(options={})
      @backend = Cant.backend
      @raise = true
    end

    # return true if any rule is true
    # else raise Cant::Unauthorized
    def can?(context={})
      return true if rules.any? {|rule| rule.call(context)}
      raise Cant::Unauthorized.new(%{can't you do that?\n#{context}}) if @raise
      false
    end

    # add a rule that when context is met, then response is what block evaluates to
    # block can have up one argument
    # - the context of invocation
    # eg :
    #  rooms = [:kitchen] 
    #  backend.can {|context| rooms.include?(context[:room]) and context[:user]}
    # 
    def can(&block)
      rules << block
    end

    private
    def rules
      @rules ||= []
    end    
  end
  
  class Unauthorized < RuntimeError; end
end
