require 'spec_helper'

module Cant
  module Backend
    class Code
      def can?(user, perform, something)
      end
    end
  end
end


describe Cant::Backend::Code do  
  it "cant do a thing" do
    backend = Cant::Backend::Code.new
    backend.can?(nil, :do, :thing)
  end
end