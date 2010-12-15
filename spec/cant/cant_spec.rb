require 'spec_helper'

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


describe Cant::Backend::Code do
  let(:backend) {Cant::Backend::Code.new}

  context "empty, no rulez" do
    it "raises!" do
      e = rescuing {
        backend.can?(:eat => :that)
      }
      assert {e.kind_of?(Cant::Unauthorized)}
      assert {e.message =~ /^can't you do that?/}
    end
  end

  context "with one rule" do
    it 'can do when at least one rule enables' do
      backend.can(:eat => :that) {true}
      assert {backend.can?(:eat => :that) == true}
    end
  end
end

describe Cant::Backend::Code::Rule do
  describe "#new" do
    it 'accept options' do
      rule = Cant::Backend::Code::Rule.new(:who => :baby)
    end 
  end
    
  context 'with a block' do
    describe '#can?' do
      it 'evaluates block, yielding params' do
        yes = Cant::Backend::Code::Rule.new {true}
        assert {yes.can?}
      end
      it 'return value of block' do
        no = Cant::Backend::Code::Rule.new {false}
        deny {no.can?}
      end
      it 'closure has instance context at hand' do
        maybe = Cant::Backend::Code::Rule.new(:eat => :cheese) {|context| 
          true if context[:eat] == :cheese
        }
        assert {maybe.can?(:eat => :cheese)}
        deny {maybe.can?(:eat => :shoe)}
      end
    end
  end
end

