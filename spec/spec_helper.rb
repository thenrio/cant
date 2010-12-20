require 'rspec'
require 'wrong/adapters/rspec'
RSpec.configure do |configuration|
end

(require 'simplecov'; SimpleCov.start) if ENV['COVERAGE']
