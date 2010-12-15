require 'spec_helper'

module Cant
  module Backend
    class Code
      def can?(user, perform, something)
        raise Cant::Unauthorized.new(%{can't you do that?})
      end
    end
  end

  class Unauthorized < RuntimeError; end
end


describe Cant::Backend::Code do
  let(:backend) {Cant::Backend::Code.new}
  
  context "empty, no rulez" do
    it "raises!" do
      e = rescuing {
        backend.can?(nil, :do, :thing)
      }
      assert {e.kind_of?(Cant::Unauthorized)}
      assert {e.message =~ /^can't you do that?/}
    end
  end
end