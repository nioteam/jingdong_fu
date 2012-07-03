Gem::Specification.new do |s|
  s.name        = 'jingdong_fu'
  s.version     = '1.0'
  s.summary     = "Ruby client for JOS platform."
  s.description = "Ruby client for JOS platform."
  s.authors     = ["nioteam"]
  s.email       = 'info@networking.io'
  s.files       = Dir['MIT-LICENSE', 'README.markdown', 'Rakefile', 'lib/**/*']
  s.homepage    = 'http://www.networking.io'

  s.add_dependency('crack', '>= 0.1.7')
end