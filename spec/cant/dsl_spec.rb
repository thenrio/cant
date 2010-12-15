require 'spec_helper'
require 'cant/dsl'

describe Cant::Dsl do
  it "can be mixed in" do
    assert {Cant::Dsl.is_a? Module}
  end
end