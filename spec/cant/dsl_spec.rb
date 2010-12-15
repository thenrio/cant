require 'spec_helper'
require 'cant/dsl'

describe Cant::Dsl do
  it "can be mixed in" do
    assert {Cant::Dsl.is_a? Module}
  end
  
  context "mixed in" do
    let(:device) {o = Object.new; o.extend(Cant::Dsl); o}
    it "provides a backend accessor" do
      device.backend = :foo
      assert {device.backend == :foo}
    end
    
    it "provide a can method" do
      device.can {true}
    end
  end
end