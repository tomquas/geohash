jruby = !!()

Gem::Specification.new do |s|
  s.name     = "geohash"
  s.version  = '1.3'
  s.date     = "2010-09-14"
  s.summary  = "GeoHash Library for Ruby, original work by David Troy"
  s.email    = "tom@patugo.com"
  s.homepage = "http://github.com/tomquas/geohash"
  s.description = "Geohash provides support for manipulating GeoHash strings in Ruby. See http://geohash.org."
  s.has_rdoc = true
  s.authors  = ["David Troy", 'tom quas']
  if ENV['JRUBY'] || RUBY_PLATFORM =~ /java/
    s.files = Dir.glob('lib/**/*')
    s.platform = 'java'
  else
    s.files = Dir.glob('ext/*') + ['lib/geohash.rb']
    s.platform = Gem::Platform::RUBY
    s.extensions << 'ext/extconf.rb'
  end
  s.test_files = ["test/test_geohash.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["Manifest.txt", "README"]
end
