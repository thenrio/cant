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
          self.instance_eval {
            return @block.call(context)
          }
        end
      end
    end
  end

  class Unauthorized < RuntimeError; end
end
