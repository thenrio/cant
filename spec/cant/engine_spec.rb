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
      predicate, die = proc {:predicate}, proc {:die}
      rule = editable.cant :predicate => predicate, :die => die
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
  
  describe "#die" do
    it 'provide default die function for this engine rules' do
      editable.die{:im_not_dead}
      assert {editable.cant.die.call == :im_not_dead}
    end
    it "returns top level response function as a fall case" do
      Cant.die{2}
      assert {editable.cant.die.call == 2}      
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

describe Cant::Questionable do
  include Cant::Questionable
  # query
  describe '#cant?' do
    let(:admin) {Stunt.new(:admin => true)}
    let(:user) {Stunt.new(:admin => false)}
    
    before do
      configuration.cant{|context| context[:url] =~ /admin/ and context[:user].admin?}
    end
    it 'authorize admin on /admin/users' do
      assert {cant?(:url => '/admin/users', :user => admin)}
    end
    it 'deny user on /admin/users' do
      deny {cant?(:url => '/admin/users', :user => user)}
    end
  end
  
  # query or die
  describe '#cant!' do
    it "return die function evaluation" do
      configuration.cant{true}.die{1}
      assert {die_if_cant! == 1}
    end
  end
end

describe Cant::Rule do
  let(:rule) {Cant::Rule.new}
  describe "#die, #die!" do
    it 'die! return call of die block' do
      rule.die {1}
      assert {rule.die! == 1}
    end
  end
end

describe Cant::Strategies do
  describe "#first_rule_that_predicates" do
    it 'carries all tailing args to closure (there is a first unused one)' do
      rule = Cant::Rule.new(proc {|x,y| x+y==10})
      deny {Cant::Strategies.first_rule_that_predicates([rule], nil, 2, 7)}
      assert {Cant::Strategies.first_rule_that_predicates([rule], nil, 2, 8) == rule}
    end
  end
  describe "#first_rule_that_predicates_in_receiver" do
    let(:receiver) {Stunt.new(:admin => true)}
    it 'carry args to function evaled in receiver' do
      rule = Cant::Rule.new(lambda {|x,y| admin? if (x+y == 2)})
      assert {Cant::Strategies.first_rule_that_predicates_in_receiver([rule], receiver, 1, 1)}
      assert {Cant::Strategies.first_rule_that_predicates_in_receiver([rule], receiver, 1, 1)}
    end
  end
end

describe Cant::Engine do
  let(:engine) {Cant::Engine.new}
  it 'can be configured and queried' do
    engine.cant{|x,y,z| x+y != z}.die{'bad arith'}
    deny {engine.cant?(1,2,3)}
    assert {engine.die_if_cant!(1,2,4) == 'bad arith'}
  end
end

describe Cant::Embedable do
  class Foo
    def foo?; true; end
    include Cant::Embedable
    cant {|x| 9<x if foo?}
  end
  let(:foo) {Foo.new}
  it 'can configured at class level, and be queried at instance level' do
    deny {foo.cant?(9)}
    assert {rescuing{foo.die_if_cant!(10)}.is_a? Cant::AccessDenied}
  end
end
