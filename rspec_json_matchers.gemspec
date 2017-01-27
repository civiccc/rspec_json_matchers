Gem::Specification.new do |s|
  s.name        = 'rspec_json_matchers'
  s.version     = '0.0.1'
  s.date        = '2017-01-26'
  s.summary     = 'RSpec JSON Matchers'
  s.description = 'JSON matchers for RSpec'
  s.authors     = ['Ryan Fitzgerald', 'Hao Su']
  s.email       = ['rwfitzge@gmail.com', 'me@haosu.org']
  s.homepage    = 'https://github.com/brigade/rspec_json_matchers/'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'activesupport', '~> 4.0', '>= 4.0.2'

  s.add_runtime_dependency 'rspec', '~> 3.0'
  s.add_runtime_dependency 'activesupport', '~> 4.0', '>= 4.0.2'

  s.files = Dir['Gemfile'] +
            Dir['LICENSE'] +
            Dir['README.md'] +
            Dir['CHANGES.md'] +
            Dir['**/*.rb']

  s.require_paths = ['lib']
end
