module Photoaway
	class MetadataCleaner
		def initialize(config)
			@config = config
		end

		def clean(fields)
			fields_clean = fields.dup
			fields_clean.each_pair do |field, value|
				value_clean = clean_value(field, value)
				fields_clean[field] = value_clean
			end

			return fields_clean
		end

		def clean_value(field, value)
			field_patterns = @config.clean_patterns[field]
			if field_patterns.nil?
				return value
			end

			field_patterns.each do |match, replacement|
				if match === value
					# FIXME: gsub?
					return replacement
				end
			end

			return value
		end
	end
end

# This is free software released into the public domain (CC0 license).
