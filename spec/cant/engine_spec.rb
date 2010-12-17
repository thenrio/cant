require 'spec_helper'
require 'cant'
require 'stunts/stunt'

describe Cant.rules do
  it 'can be read, and respond to each' do
    assert {Cant.rules.respond_to? :each}
  end
end

describe Cant::Engine do
  let(:engine) {Cant::Engine.new}

  describe '#raising' do
    it 'returns self and sets @raise option' do
      assert {engine.raising?}
      assert {engine.raising(false) == engine}
      deny {engine.raising?}
    end
  end

  context "empty, no rulez" do
    it "raises!" do
      e = rescuing {
        engine.can?(:eat => :that)
      }
      assert {e.kind_of?(Cant::Unauthorized)}
      assert {e.message =~ /^can't you do that?/}
    end
  end

  context "with one rule" do
    before do
      engine.can {:all}
    end
    it 'can do when at least one rule enables' do
      assert {engine.can?(:eat => :that) == true}
    end
    it 'does not creep in module rules' do
      deny {Cant.rules.include? engine.send(:rules).first}
    end
  end
  
  # integration|value test
  context 'with an admin and a user' do
    let(:admin) {Stunt.new(:admin => true)}
    let(:user) {Stunt.new(:admin => false)}
    let(:engine) {Cant::Engine.new}
    
    before do
      engine.can {|context| context[:url] =~ /admin/ and context[:user].admin?}
    end
    it 'authorize admin on /admin/users' do
      assert {engine.can?(:url => '/admin/users', :user => admin)}
    end
    it 'deny user on /admin/users' do
      deny {engine.raising(false).can?(:url => '/admin/users', :user => user)}
    end
  end
  
  describe '#strategy' do
    let(:engine) {Cant::Engine.new(:raising => false)}
    it 'accept a block, with a rules argument, that can return true or false' do
      context = true
      engine.strategy {context}
      assert {engine.can?}
      context = false
      deny {engine.can?}      
    end
  end
end

describe Cant::Strategies do
  describe "#true_if_any_true" do
    it 'is a function returning any? on enumeration, and call on each' do
      rules = []
      deny {Cant::Strategies.true_if_any_true([])}
      rules << proc {true} 
      assert {Cant::Strategies.true_if_any_true(rules)}
    end
  end
end
