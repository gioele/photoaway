require 'filepath'
require 'inifile'
require 'userdirs'

require 'photoaway/errors'

module Photoaway
	class Configuration
		DEFAULTS = {
			:root => '~/Pictures', # FIXME: use Userdirs
			:mode => :move,
			:verbose => false,
			:use_utc => false,
			:directory_template => '%{Y}-%{m}-%{d}',
		}

		OPTION_NAMES = DEFAULTS.keys

		def initialize(cmdline_options = nil)
			cmdline_options ||= {}
			config_options = config_file_options

			@options = DEFAULTS.merge(config_options).merge(cmdline_options)

			check_option_values
			fixup_values

			if @options[:verbose]
				msg_fn_verbose = lambda { |&block| $stderr.puts yield }
				@options[:msg_fn] = msg_fn_verbose
			end
		end

		def config_file_options
			cfg_file_path = Userdirs.config_file_user('photoaway', 'config')
			cfg_file = IniFile.load(cfg_file_path)
			cfg = cfg_file['global']

			options = cfg.map { |k, v| [k.to_sym, v] }.to_h

			options[:clean_patterns] = {}

			clean_sections = cfg_file.sections.grep(/^clean_metadata\//)
			clean_sections.each do |section_name|
				section = cfg_file[section_name]

				field = section_name.sub(/^clean_metadata\//, '').to_sym
				patterns = section.keys.grep(/^pattern_.*_match$/)

				options[:clean_patterns][field] = patterns.map do |pattern|
					match = section[pattern]
					replace = section[pattern.sub(/_match$/, '_replace')]

					next [match, replace]
				end
			end

			return options
		end

		def check_option_values
			if ![:copy, :move].include?(@options[:mode].to_sym)
				value = @options[:mode]
				raise ConfigurationError, "Unknown value '#{value}' for option :mode"
			end

			if !["true", "false"].include?(@options[:verbose].to_s)
				value = @options[:verbose]
				raise ConfigurationError, "Unknown value '#{value}' for option :verbose"
			end
		end

		def fixup_values
			@options[:mode] = @options[:mode].to_sym
			@options[:verbose] = (@options[:verbose] == "true")
		end

		def root
			if @options.has_key?(:root)
				return @options[:root].as_path.expanded_tilde
			end

			raise "NO ROOT"
		end

		def msg_fn
			return @options[:msg_fn]
		end

		def msg_info_fn
			return @options[:msg_info_fn]
		end

		def msg_err_fn
			return @options[:msg_err_fn]
		end

		def path_directory_template
			return @options[:directory_template]
		end

		def move?
			return @options[:mode] == :move
		end

		def clean_patterns
			return @options[:clean_patterns]
		end
	end
end

# This is free software released into the public domain (CC0 license).
