module Cant
  module Backend
    class Code
      # return true if any rule is true
      # else raise Cant::Unauthorized
      def can?(context)
        raise Cant::Unauthorized.new(%{can't you do that?\n#{context}}) if rules.empty?
        true
      end

      # add a rule that when context is met, then response is what block evaluates to
      # block can have up to two arguments
      # - the context of invocation
      # - the context of definition of this rule
      # eg : 
      #   cook.can(:rooms => [:kitchen]) {|context, restriction| 
      #     return context[:user] and restriction[:rooms].include? context[:room]
      #  }
      # 
      def can(context, &block)
        rules << Rule.new(context, &block)
      end

      private
      def rules
        @rules ||= []
      end

      class Rule
        def initialize(context={}, &block)
          @context = context
          @block = block
        end
        def can?(context={})
          return @block.call(context, @context)
        end
      end
    end
  end

  class Unauthorized < RuntimeError; end
end
