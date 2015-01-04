require 'filepath'

require 'photoaway/configuration'
require 'photoaway/errors'
require 'photoaway/mover'
require 'photoaway/picture'

module Photoaway
	class CLI
		def run(args)
			begin
				cmdline_options = parse_args(args)
				config = Photoaway::Configuration.new(cmdline_options)
			rescue ConfigurationError => e
				$stderr.puts "ERROR: #{e.message}"
				exit 1
			end

			source_path = args.first.as_path
			pics_paths = source_path.files(recursive: true).to_a
			pics = pics_paths.map { |path| Photoaway::Picture.for(path) }
			pics.compact!

			mover = Photoaway::Mover.new(config)
			outcomes = Hash.new(0)
			pics.each do |photo|
				outcome = mover.move(photo)
				outcomes[outcome] += 1
			end

			print_summary(outcomes)
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
	end
end

# This is free software released into the public domain (CC0 license).
