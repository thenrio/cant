require 'spec_helper'
require 'cant'
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
        maybe = Cant::Backend::Code::Rule.new(:eat => :cheese) {|context| true if context[:eat] == :cheese}
        assert {maybe.can?(:eat => :cheese)}
        deny {maybe.can?(:eat => :shoe)}
      end
    end
  end
end

