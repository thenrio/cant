require 'spec_helper'
require 'cant/embeddable'

describe Cant::Embeddable do
  class Foo
    def foo?; true; end
    include Cant::Embeddable
    cant {|x| 9<x if foo?}
  end
  class Bar < Foo
    def foo?; false; end
    def bar?; true; end
    cant {|x| x>20 if bar?}
    die {true}
  end
  describe 'including class' do
    it 'can configured, and instance be queried' do
      foo = Foo.new
      deny {foo.cant?(9)}
      assert {rescuing{foo.die_if_cant!(10)}.is_a? Cant::AccessDenied}
    end
  end 
  describe 'subclass' do
    # this does not work !!!
    # 
    # it 'has base class callback called' do
    #   assert {bar.imposterized?}
    # end
    it 'has superclass and self rules' do
      assert {Bar.rules.length == 2}
    end
    it 'subclass can use it' do
      bar = Bar.new
      bar.cant?(10)
      assert {bar.cant?(21)}
    end
    # XXX this might be considered as a bug
    it 'does not gain superclass rules when modified after class loading' do
      Foo.rules << :whop
      deny {Bar.rules.include? :whoop}
    end
  end
end
