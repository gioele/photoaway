require 'spec_helper'
require 'photoaway/configuration'
require 'photoaway/picture'

require 'photoaway/metadata_cleaner'

RSpec.describe Photoaway::MetadataCleaner do
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

		@fields = {
			:camera_maker => 'TestMaker',
			:camera_model => 'TestCamera',
			:Y => 2016,
			:m => 01,
			:d => 16,
		}
	end

	it "cleans the `camera_maker` field" do
		settings = @base_settings.dup
		settings[:clean_patterns] = {
			:camera_maker => [
				["TestProducer", "TEST-PRODUCER"],
				["TestMaker", "TEST-MAKER"],
			]
		}
		cfg = Photoaway::Configuration.new(settings)
		metadata_cleaner = Photoaway::MetadataCleaner.new(cfg)

		fields_clean = metadata_cleaner.clean(@fields)
		fields_clean[:camera_maker].should eq("TEST-MAKER")
		@fields[:camera_maker].should eq("TestMaker")
	end

	it "ignores patterns for other fields" do
		settings = @base_settings.dup
		settings[:clean_patterns] = {
			:camera_model => [
				["TestProducer", "TEST-PRODUCER"],
				["TestMaker", "TEST-MAKER"],
			]
		}

		cfg = Photoaway::Configuration.new(settings)
		metadata_cleaner = Photoaway::MetadataCleaner.new(cfg)

		fields_clean = metadata_cleaner.clean(@fields)
		fields_clean[:camera_maker].should eq("TestMaker")
		fields_clean.should == @fields
	end
end
