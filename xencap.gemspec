g = Gem::Specification.new do |s|
  s.name        = 'xencap'
  s.version     = '1.2.0'
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Capistrano support for managing XenServer"
  s.description = "Should work with any xen system that uses XAPI (including XenServer & XCP)"
  s.authors     = ["Patrick Schless"]
  s.email       = 'patrick@plainlystated.com'
  s.files       = Dir[File.dirname(__FILE__) + "/lib/**/*.rb"]
  s.homepage    = 'https://github.com/plainlystated/xencap'
end
