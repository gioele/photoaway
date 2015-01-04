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
			dest_path_abs = dest_path.absolute_path

			if dest_path.exist?
				same = FileUtils.identical?(src_path, dest_path_abs)
				if same
					msg_err { "Destinaton file #{dest_path} already exists (identical), skipping" }
					return :exist_same
				else
					msg_err { "Destinaton file #{dest_path} already exists with different content, skipping" }
					return :exist_different
				end
			end

			msg { op = @cfg.move? ? 'moving' : 'copying' ; "#{op} #{src_path} to #{dest_path}" }

			FileUtils.mkdir_p(dest_path.parent_dir.absolute_path)

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
			# FIXME: use @cfg.msg_fn
			puts yield
		end

		def msg_err
			$stderr.puts yield
		end
	end
end

# This is free software released into the public domain (CC0 license).
