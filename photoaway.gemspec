lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'photoaway/version'

Gem::Specification.new do |spec|
	spec.name          = 'photoaway'
	spec.version       = Photoaway::VERSION
	spec.authors       = ['Gioele Barabucci']
	spec.email         = ['gioele@svario.it']
	spec.summary       = 'Copy your photo and organize them. Stop.'
	spec.description   = 'photoaway does only one thing: it copies ' +
	                     'your photos from your camera or a SD card to ' +
	                     'your disk, organizing them in folders ' +
	                     'based on the pictures\' metadata. ' +
	                     'No image viewers, no post-processing, ' +
	                     'only file organization.'
	spec.homepage      = 'http://svario.it/photoaway'
	spec.license       = 'CC0'

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_dependency 'exifr'
	spec.add_dependency 'filepath'
	spec.add_dependency 'inifile'
	spec.add_dependency 'userdirs'

	spec.add_development_dependency 'bundler', '~> 1.6'
	spec.add_development_dependency 'rake'
	spec.add_development_dependency 'rspec'
end

# This is free software released into the public domain (CC0 license).
