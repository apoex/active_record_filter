require File.expand_path('../lib/active_record_filter/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'active_record_filter'
  s.version     = ActiveRecordFilter::VERSION
  s.date        = '2019-03-03'
  s.summary     = 'Step by step filters for ActiveRecord'
  s.description = 'Break large filters into components and see how each ' + \
                  'component affects the result'
  s.authors     = ['Love Ottosson']
  s.email       = 'love.ottosson@apoex.se'
  s.files       = ['lib/active_record_filter.rb']
  s.homepage    = 'https://github.com/apoex/active_record_filter'
  s.license     = 'MIT'

  s.add_runtime_dependency 'activerecord', '>= 4', '< 6'
  s.add_development_dependency 'rake', '< 13'
  s.add_development_dependency 'minitest', '< 6'
  s.add_development_dependency 'sqlite3', '< 1.4'
end
