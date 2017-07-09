require 'exifr'

require 'photoaway/errors'

module Photoaway
	class Picture
		def initialize(path)
			@path = path
		end

		attr_reader :path

		def self.for(path)
			if !is_picture(path)
				return nil
			end

			return self.new(path)
		end

		def self.is_picture(path)
			return path.extension =~ /(jpe?g)|(ra?w2?)/i
		end

		def raw_metadata
			if @path.extension =~ /jpe?g/i
				return EXIFR::JPEG.new(@path.to_s)
			else
				return EXIFR::TIFF.new(@path.to_s)
			end
		end

		def metadata
			data = raw_metadata

			fields = {}

			fields[:camera_maker] = data.make
			fields[:camera_model] = data.model
			fields[:date_time] = data.date_time_original || data.date_time

			fields.each_pair do |field, value|
				if value.nil?
					raise NoMetadataError, "Could not extract metadata field #{field}"
				end
			end

			date = fields[:date_time].strftime('%Y-%m-%d').split('-')
			fields[:Y] = date[0]
			fields[:m] = date[1]
			fields[:d] = date[2]

			return fields
		end
	end
end

# This is free software released into the public domain (CC0 license).
