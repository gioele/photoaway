require 'filepath'
require 'fileutils'
require 'exifr'

require 'photoaway/errors'

module Photoaway
	class Mover
		def initialize(config)
			@cfg = config
		end

		def move(picture)
			begin
				src_path = picture.path
				dest_subpath = compiled_path(picture)
			rescue Photoaway::NoMetadataError => e
				msg_err { "Skipping #{src_path}: metadata error: #{e}." }
				return :error
			rescue EXIFR::MalformedJPEG
				msg_err { "Skipping #{src_path}: malformed JPEG." }
				return :error
			end

			dest_path = @cfg.root / dest_subpath
			dest_path_abs = dest_path.absolute_path

			if dest_path.exist?
				same = FileUtils.identical?(src_path, dest_path_abs)
				if same
					msg_info { "Skipping #{src_path}: destinaton file #{dest_path} already exists (identical)." }
					return :exist_same
				else
					msg_err { "Skipping #{src_path}: destinaton file #{dest_path} already exists with different content." }
					return :exist_different
				end
			end

			dest_path_removed = @cfg.root / dest_subpath.add_extension('removed')
			if dest_path_removed.exist?
				msg_info { "Skipping #{src_path}: destination marked as removed, placeholder file #{dest_path_removed} found." }
				return :removed_placeholder_found
			end

			msg { op = @cfg.move? ? 'moving' : 'copying' ; "#{op} #{src_path} to #{dest_path}" }

			dest_path.parent_dir.absolute_path.mkdir_p

			if @cfg.move?
				FileUtils.mv(src_path, dest_path_abs)
			else
				FileUtils.cp(src_path, dest_path_abs)
			end

			return :moved
		end

		def compiled_path(picture)
			filename = picture.path.filename

			metadata = picture.metadata
			directory = @cfg.path_directory_template % metadata

			return directory.as_path / filename
		end

		def msg
			if !@cfg.msg_fn.nil?
				@cfg.msg_fn[yield]
			else
				puts yield
			end
		end

		def msg_info
			if !@cfg.msg_info_fn.nil?
				@cfg.msg_info_fn[yield]
			else
				puts yield
			end
		end

		def msg_err
			if !@cfg.msg_err_fn.nil?
				@cfg.msg_err_fn[yield]
			else
				$stderr.puts yield
			end
		end
	end
end

# This is free software released into the public domain (CC0 license).
