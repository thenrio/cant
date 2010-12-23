require 'spec_helper'
require 'models/user'

describe User do
  before do
    User.strategy do |rules, receiver, env|
      Cant::Strategies.first_rule_that_predicates_in_receiver(rules, receiver, env)
    end
    User.cant do |env|
      env[:path] =~ /^\/admin/ unless admin?
    end
  end
  
  context "without being an admin" do
    let(:user) {User.new}
    it 'can not access /admin ' do
      assert {user.cant?(:path => '/admin')}
    end
  end
end