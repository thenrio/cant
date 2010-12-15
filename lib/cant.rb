module Cant
  module Backend
    class Code
      # return true if any rule is true
      # else raise Cant::Unauthorized
      def can?(context={})
        raise Cant::Unauthorized.new(%{can't you do that?\n#{context}}) if rules.empty?
        true
      end

      # add a rule that when context is met, then response is what block evaluates to
      # block can have up one argument
      # - the context of invocation
      # eg :
       #  rooms = [:kitchen] 
       #  backend.can {|context| rooms.include?(context[:room]) and context[:user]}
      # 
      def can(&block)
        rules << Rule.new(&block)
      end

      private
      def rules
        @rules ||= []
      end

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
