
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mkrdashboards/version"

Gem::Specification.new do |spec|
  spec.name          = "mkrdashboards"
  spec.version       = Mkrdashboards::VERSION
  spec.authors       = ["fullsat"]
  spec.email         = ["fullsat310@gmail.com"]

  spec.summary       = %q{Mackerel dashboard maker}
  spec.description   = %q{This tool make easy to create a column type dashboard.}
  spec.homepage      = "https://github.com/fullsat/mkrdashboards/"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "faraday"
  spec.add_dependency "thor"
  spec.add_dependency "dotenv"
  spec.add_dependency "json"
end
