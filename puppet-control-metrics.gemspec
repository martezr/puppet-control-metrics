Gem::Specification.new do |spec|
  spec.name        = 'puppet-control-metrics'
  spec.version     = '0.0.1'
  spec.date        = '2017-02-17'
  spec.summary     = "Generate puppet control repo metrics"
  spec.description = "A"
  spec.authors     = ["Martez Reed"]
  spec.email       = 'martez.reed@greenreedtech.com'
  spec.files       = ["lib/puppet-control-metrics.rb"]
  spec.homepage    =
    'http://rubygems.org/gems/puppet-control-metrics'
  spec.license       = 'Apache-2.0'
  spec.add_dependency 'git'
  spec.add_dependency 'r10k'
  spec.add_dependency 'puppet'
end
