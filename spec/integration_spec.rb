require 'spec_helper'
require 'models/user'

describe User do
  before do
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