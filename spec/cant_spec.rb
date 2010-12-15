require 'spec_helper'
require 'cant'
require 'stunts/stunt'

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
      backend.can {:all}
      assert {backend.can?(:eat => :that) == true}
    end
  end
  
  # integration|value test
  context 'with an admin and a hacker' do
    let(:admin) {Stunt.new(:admin => true)}
    let(:user) {Stunt.new(:admin => false)}
    let(:backend) {Cant::Backend::Code.new}
    
    before do
      backend.can {|context| context[:url] =~ /admin/ and context[:user].admin?}
    end
    it 'authorize admin on /admin/users' do
      assert {backend.can?(:url => '/admin/users', :user => admin)}
    end
    it 'deny user on /admin/users' do
      deny {backend.can?(:url => '/admin/users', :user => user)}
    end
  end
end

describe Cant::Backend::Code::Rule do    
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
      maybe = Cant::Backend::Code::Rule.new {|context| true if context[:eat] == :cheese}
      assert {maybe.can?(:eat => :cheese)}
      deny {maybe.can?(:eat => :shoe)}
    end
  end
end
