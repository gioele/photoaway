require 'bundler/setup'

RSpec.configure do |config|
	config.filter_run_excluding :broken => true

	config.expect_with :rspec do |c|
		c.syntax = [:should, :expect]
	end
end
