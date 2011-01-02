require 'spec_helper'
require 'cant'
require 'stunts/stunt'

describe Cant do
  it 'has fold default value to first_rule_that_predicates_in_receiver' do
    Cant.cant {|x| include? x}
    a = [1]
    assert {Cant.fold.call(Cant.rules, a, 1)}
  end
  it 'has a raising die function' do
    e = rescuing {Cant.die.call(:do, :that)}
    assert {e.is_a? Cant::AccessDenied}
    assert {e.message =~ /^Cant you do that.*\?$/}
  end
  it 'rules is enumerable' do
    assert {Cant.rules.respond_to? :each}
  end
  after do
    Cant.rules.clear
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

  describe '#fold' do
    context 'with a block' do
      it 'sets the fold proc' do
        editable.fold {:onoes}
        assert {editable.fold.call == :onoes}
      end
    end
  end
  
  describe "#die" do
    before do
      # XXX preserving default value for class instance variable
      @proc=Cant.instance_variable_get(:@die)
      Cant.die{2}
    end
    it 'provide default die function for this engine rules' do
      editable.die{:im_not_dead}
      assert {editable.cant.die.call == :im_not_dead}
    end
    it "returns top level response function as a fall case" do
      assert {editable.cant.die.call == 2}      
    end
    after do
      Cant.instance_variable_set(:@die, @proc)
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
      cantfiguration.cant{|context| context[:url] =~ /admin/ and context[:user].admin?}
    end
    it 'authorize admin on /admin/users' do
      assert {cant?(:url => '/admin/users', :user => admin)}
    end
    it 'deny user on /admin/users' do
      deny {cant?(:url => '/admin/users', :user => user)}
    end
  end
  
  # query or die
  describe '#die_if_cant!' do
    it "return die function evaluation" do
      cantfiguration.cant{true}.die{1}
      assert {die_if_cant! == 1}
    end
  end
  
  it 'cant be given a cantfiguration' do
    self.cantfiguration = 1
    assert{cantfiguration == 1}
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

describe Cant::Folds do
  describe "#first_rule_that_predicates" do
    it 'carries all tailing args to closure (there is a first unused one)' do
      rule = Cant::Rule.new(proc {|x,y| x+y==10})
      deny {Cant::Folds.first_rule_that_predicates([rule], nil, 2, 7)}
      assert {Cant::Folds.first_rule_that_predicates([rule], nil, 2, 8) == rule}
    end
  end
  describe "#first_rule_that_predicates_in_receiver" do
    let(:receiver) {Stunt.new(:admin => true)}
    it 'carry args to function evaled in receiver' do
      rule = Cant::Rule.new(lambda {|x,y| admin? if (x+y == 2)})
      assert {Cant::Folds.first_rule_that_predicates_in_receiver([rule], receiver, 1, 1)}
      assert {Cant::Folds.first_rule_that_predicates_in_receiver([rule], receiver, 1, 1)}
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
