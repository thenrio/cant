module Cant
  class Engine
    attr_accessor :backend
    attr_writer :raise
    
    def initialize
      @backend = Backends::Simple.new
      @raise = true
    end

    # return true if any rule is true
    # else raise Cant::Unauthorized
    def can?(context={})
      return true if rules.any? {|rule| rule.can? context}
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
      rules << backend.rule(&block)
    end

    private
    def rules
      @rules ||= []
    end    
  end

  module Backends    
    class Simple
      def rule(&block)
        Rule.new(&block)
      end
      
      private
      class Rule
        def initialize(&block)
          @block = block
        end
        def can?(context={})
          return @block.call(context)
        end
      end
    end
  end

  class Unauthorized < RuntimeError; end
end
