Gem::Specification.new do |s|
  s.name        = 'word_templater'
  s.version     = '0.0.3'
  s.date        = '2012-08-03'
  s.summary     = "Uses a .docx as a template and replaces 'tags' within || with other content"
  s.description = "Uses a .docx file with keyword tags within '||' as a template. This gem will then open the .docx and replace those tags with dynamically defined content."
  s.authors     = ["Paul Smith"]
  s.email       = 'pauls@basecampops.com'
  s.files       = ["lib/word_templater.rb"]
  s.add_runtime_dependency "rubyzip", ["~> 0.9.9"]
  s.homepage    = 'http://rubygems.org/gems/word_templater'
end