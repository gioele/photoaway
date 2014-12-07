require 'filepath'
require 'fileutils'

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
			rescue Photoaway::NoMetadataError
				msg_err { "Metadata error in #{src_path}, skipping." }
				return :error
			end

			dest_path = @cfg.root / dest_subpath

			if dest_path.exist?
				msg_err { "Destinaton file #{dest_path} already exist, skipping" }
				return :skipped
			end

			msg { op = @cfg.move? ? 'moving' : 'copying' ; "#{op} #{src_path} to #{dest_path}" }

			FileUtils.mkdir_p(dest_path.parent_dir.absolute_path)

			if @cfg.move?
				FileUtils.mv(src_path, dest_path.absolute_path)
			else
				FileUtils.cp(src_path, dest_path.absolute_path)
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
			# FIXME: use @cfg.msg_fn
			puts yield
		end

		def msg_err
			$stderr.puts yield
		end
	end
end

# This is free software released into the public domain (CC0 license).
