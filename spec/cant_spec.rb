require 'spec_helper'
require 'cant'
require 'stunts/stunt'

describe Cant::Engine do
  let(:engine) {Cant::Engine.new}

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
    it 'can do when at least one rule enables' do
      engine.can {:all}
      assert {engine.can?(:eat => :that) == true}
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
      engine.raise = false
      deny {engine.can?(:url => '/admin/users', :user => user)}
    end
  end
end

describe Cant::Backends::Simple::Rule do    
  describe '#can?' do
    it 'evaluates block, yielding params' do
      yes = Cant::Backends::Simple::Rule.new {true}
      assert {yes.can?}
    end
    it 'return value of block' do
      no = Cant::Backends::Simple::Rule.new {false}
      deny {no.can?}
    end
    it 'closure has instance context at hand' do
      maybe = Cant::Backends::Simple::Rule.new {|context| true if context[:eat] == :cheese}
      assert {maybe.can?(:eat => :cheese)}
      deny {maybe.can?(:eat => :shoe)}
    end
  end
end

