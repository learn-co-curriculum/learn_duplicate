Gem::Specification.new do |s|
  s.name = 'learn_duplicate'
  s.version = '0.0.6'
  s.date = '2019-04-23'
  s.authors = ['flatironschool']
  s.email = 'maxwell@flatironschool.com'
  s.license = 'MIT'
  s.summary = 'learn_duplicate is a tool for duplicating learn.co lessons on github'
  s.files = Dir.glob('{bin,lib}/**/*') + %w[LICENSE.md README.md CONTRIBUTING.md Rakefile Gemfile]
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/learn-co-curriculum/learn_duplicate'
  s.executables << 'learn_duplicate'
  s.add_runtime_dependency 'faraday', '~> 0.15'
end
