require 'spec_helper'
require 'cant'
require 'stunts/stunt'

describe Cant.rules do
  it 'can be read, and respond to each' do
    assert {Cant.rules.respond_to? :each}
  end
end

describe Cant::Editable do
  let(:editable) {Object.new.extend Cant::Editable}
  describe "#cant" do
    it 'returns a Cant::Rule' do
      rule = editable.cant {true}
      assert {rule.is_a? Cant::Rule}
    end
    it 'accepts an option argument, that can provide both predicate and response functions' do
      predicate, response = proc {:predicate}, proc {:response}
      rule = editable.cant :predicate => predicate, :response => response
      assert {rule.predicate == predicate}
    end
  end

  describe '#strategy' do
    context "with no args" do
      it 'return a proc' do
        assert {editable.strategy.is_a? Proc}
      end
    end
    context 'with a block' do
      it 'sets the strategy proc' do
        editable.strategy {:onoes}
        assert {editable.strategy.call == :onoes}
      end
    end
  end
  
  describe "#respond" do
    it 'provide default response function for this engine rules' do
      editable.respond{:cant}
      assert {editable.cant.response.call == :cant}
    end
    it "returns top level response function as a fall case" do
      Cant.respond{2}
      assert {editable.cant.response.call == 2}      
    end    
  end
  
  describe "rules" do
    it 'cant does not creep in module rules' do
      editable.cant {true}
      deny {Cant.rules.include? editable.rules.first}
    end
    it 'has module rules first' do
      Cant.rules << :first
      assert {editable.rules == [:first]}
    end
    after do
      Cant.rules.clear
    end
  end  
end

describe Cant::Engine do
  let(:engine) {Object.new.extend Cant::Engine}

  # dsl test
  describe '#cant?' do
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
  
  describe '#cant!' do
    it "return response function evaluation" do
      engine.cant{true}.respond{1}
      assert {engine.cant! == 1}
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
  describe "#first_rule_that_predicates" do
    it 'return first rule that cant, false either' do
      deny {Cant::Strategies.first_rule_that_predicates([])}
      rule = Cant::Rule.new(proc {true})
      assert {Cant::Strategies.first_rule_that_predicates([rule]) == rule}
    end
  end
end
