require 'spec_helper'
require 'cant/dsl'

describe Cant::Dsl do
  it "can be mixed in" do
    assert {Cant::Dsl.is_a? Module}
  end
  
  context "mixed in" do
    let(:device) {o = Object.new; o.extend(Cant::Dsl); o}
    it "provides a cant method" do
      assert {device.cant.is_a? Cant::Engine}
    end

    it "delegates can" do
      device.can {true}
      assert {device.can?}
    end
  end
end
