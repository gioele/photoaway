require 'filepath'
require 'time'

require 'photoaway/configuration'
require 'photoaway/errors'
require 'photoaway/mover'
require 'photoaway/picture'

module Photoaway
	class CLI
		def run(args)
			now = Time.now
			@import_date = now.iso8601
			@import_id = now.to_i

			begin
				cmdline_options = parse_args(args)

				extra_options = {}
				# FIXME: control with command line options
				extra_options[:msg_fn] = lambda { |msg| process_msg(msg) }
				extra_options[:msg_info_fn] = lambda { |msg| process_msg(msg) }
				extra_options[:msg_err_fn] = lambda { |msg| process_error_msg(msg) }

				options = cmdline_options.merge(extra_options)
				@config = Photoaway::Configuration.new(options)
			rescue ConfigurationError => e
				$stderr.puts "ERROR: #{e.message}"
				exit 1
			end

			@log = log_file
			@log.puts "Import session started at #{Time.now}"

			source_path = args.first.as_path
			pics_paths = source_path.files(recursive: true).to_a
			pics = pics_paths.map { |path| Photoaway::Picture.for(path) }
			pics.compact!

			mover = Photoaway::Mover.new(@config)
			outcomes = Hash.new(0)
			pics.each do |photo|
				outcome = mover.move(photo)
				outcomes[outcome] += 1
			end

			print_summary(outcomes)

			@log.puts "Import session ended at #{Time.now}"
		end

		def parse_args(args)
			if args.size < 1
				raise "USAGE: photoaway SOURCE_DIR"
			end

			# TODO: read from cmdline

			return {}
		end

		def print_summary(outcomes)
			pics_count = outcomes.values.inject(&:+)

			num_skipped = outcomes[:exist_different]
			num_skipped += outcomes[:exist_same]
			num_errors = outcomes[:error]
			if !num_skipped.zero? || !num_errors.zero?
				$stderr.puts
				$stderr.puts "Summary:"
			end
			if !num_skipped.zero?
				$stderr.puts "\tSkipped #{num_skipped} files (out of #{pics_count} total files)"
			end
			if !num_errors.zero?
				$stderr.puts "\tCould not process #{num_errors} files (out of #{pics_count} total files)"
			end
		end

		def log_file
			log_path = @config.root / "import-#{@import_id}-#{@import_date}.log"
			return File.open(log_path, 'w')
		end

		def process_msg(msg)
			@log.puts msg
			puts msg
		end

		def process_error_msg(msg)
			formatted_msg = "ERROR: #{msg}"
			@log.puts formatted_msg
			puts formatted_msg
		end
	end
end

# This is free software released into the public domain (CC0 license).
