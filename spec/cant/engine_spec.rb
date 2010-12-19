require 'spec_helper'
require 'cant'
require 'stunts/stunt'

describe Cant.rules do
  it 'can be read, and respond to each' do
    assert {Cant.rules.respond_to? :each}
  end
end

describe Cant::Editable do
  let(:set) {Object.new.extend Cant::Editable}
  describe "#cant" do
    it 'returns a Cant::Rule' do
      rule = set.cant {true}
      assert {rule.is_a? Cant::Rule}
    end
  end
end

describe Cant::Engine do
  let(:engine) {Object.new.extend Cant::Engine}

  context "rules" do
    it 'cant does not creep in module rules' do
      engine.cant {true}
      deny {Cant.rules.include? engine.rules.first}
    end
    it 'has module rules first' do
      Cant.rules << :first
      assert {engine.rules == [:first]}
    end
    after do
      Cant.rules.clear
    end
  end
  
  # integration|value test
  context 'with an admin and a user' do
    let(:admin) {Stunt.new(:admin => true)}
    let(:user) {Stunt.new(:admin => false)}
    
    before do
      engine.cant {|context| context[:url] =~ /admin/ and context[:user].admin?}
    end
    it 'authorize admin on /admin/users' do
      assert {engine.cant?(:url => '/admin/users', :user => admin)}
    end
    it 'deny user on /admin/users' do
      deny {engine.cant?(:url => '/admin/users', :user => user)}
    end
  end
  
  describe '#strategy' do
    it 'accept a block, with a rules argument, that can return true or false' do
      context = true
      engine.strategy {context}
      assert {engine.cant?}
      context = false
      deny {engine.cant?}
    end
  end
end

describe Cant::Rule do
  let(:rule) {Cant::Rule.new}
  describe "#respond, #respond!" do
    it 'respond! return call of respond block' do
      rule.respond {1}
      assert {rule.respond! == 1}
    end
  end
end

describe Cant::Strategies do
  describe "#respond_when_first_predicate_is_true" do
    it 'is a function returning any? on enumeration, and call on each' do
      rules = []
      deny {Cant::Strategies.respond_when_first_predicate_is_true([])}
      rules << Cant::Rule.new(proc {true})
      assert {Cant::Strategies.respond_when_first_predicate_is_true(rules)}
    end
  end
end
