require 'spec_helper'

module Cant
  module Backend
    class Code
      def can?(user, perform, something)
        raise Cant::Unauthorized.new(%{can't you do that?}) if rules.empty?
        true
      end

      def can(user, perform, something)
        rules << :pop
      end

      private
      def rules
        @rules ||= []
      end

      class Rule
        def initialize(options={}, &block)
          @options = options
          @block = block
        end
        def can?
          @block.call
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
        backend.can?(nil, :do, :thing)
      }
      assert {e.kind_of?(Cant::Unauthorized)}
      assert {e.message =~ /^can't you do that?/}
    end
  end

  context "with one rule" do
    it 'can do when at least one rule enables' do
      backend.can(:fred, :do, :thing)
      assert {backend.can?(:fred, :do, :thing) == true}
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
    end
  end
end

