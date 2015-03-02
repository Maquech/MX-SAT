# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'MX/SAT/version'

Gem::Specification.new do |spec|
  spec.name          = "MX-SAT"
  spec.version       = MX::SAT::VERSION # `git describe --tags --abbrev=0`.strip
  spec.authors       = ["Pablo Ruiz"]
  spec.email         = ["pjruiz@maquech.com.mx"]
  spec.summary       = %q{Mexican taxpayers utilities / Utilerías para lidiar con Sistema de Administración Tributaria (SAT)}
  spec.description   = %q{Mexican taxpayers utilities / Utilerías para lidiar con Sistema de Administración Tributaria (SAT)}
  spec.homepage      = "https://github.com/Maquech/MX-SAT"
  spec.license       = "MIT"
  spec.post_install_message = "¡Viva México!"

  spec.required_ruby_version = '>= 1.9.3'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency 'nokogiri', '>= 1.6'
  spec.add_dependency 'simple_xlsx_reader'
  spec.add_dependency 'rubyzip'
end
