require 'spec_helper'
require 'filepath'
require 'photoaway/configuration'
require 'photoaway/picture'

require 'photoaway/mover'

RSpec.describe Photoaway::Mover do
	before(:all) do
		ignore_msg_fn = lambda { |msg| }
		@root_dir = Dir.tmpdir.as_path / 'photoaway-rspec'
		@base_settings = {
			:root => @root_dir,
			:mode => :copy,
			:verbose => :false,
			:directory_template => 'out',
			:msg_fn => ignore_msg_fn,
			:msg_info_fn => ignore_msg_fn,
			:msg_err_fn => ignore_msg_fn,
		}
		@test_pic = Photoaway::Picture.for('spec/fixtures/test-minimal.jpg'.as_path)
		@test_pic_dest = @root_dir / 'out' / @test_pic.path.filename
	end

	before(:each) do
		@root_dir.rm_rf
	end

	it "copies images" do
		cfg = Photoaway::Configuration.new(@base_settings)
		mover = Photoaway::Mover.new(cfg)

		mover.move(@test_pic).should eq(:moved)
		@test_pic_dest.should exist
	end

	it "skips already copied files" do
		cfg = Photoaway::Configuration.new(@base_settings)
		mover = Photoaway::Mover.new(cfg)

		mover.move(@test_pic).should eq(:moved)
		@test_pic_dest.should exist

		mover.move(@test_pic).should_not eq(:moved)
		@test_pic_dest.should exist
	end
end
