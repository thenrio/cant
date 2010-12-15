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
      
      # class Rule
      #   def initialize(who, can_do, what, &block)
      #     @who = who
      #     @can_do
      #   end
      #    def can?(user, perform, something)
      #    end
      # end
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