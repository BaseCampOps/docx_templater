Gem::Specification.new do |s|
  s.name        = 'docx_templater'
  s.version     = '0.1.1'
  s.date        = '2012-08-03'
  s.summary     = "Uses a .docx as a template and replaces 'tags' within || with other content"
  s.description = "Uses a .docx file with keyword tags within '||' as a template. This gem will then open the .docx and replace those tags with dynamically defined content."
  s.authors     = ["Paul Smith","Michael Ries"]
  s.email       = 'pauls@basecampops.com'
  s.files       = ["lib/docx_templater.rb",
    "lib/docx/argument_combiner.rb",
    "lib/docx/document_replacer.rb",
    "lib/docx/nodes_to_fix.rb",
    "lib/docx/placeholder_observer.rb"]
  s.add_runtime_dependency "rubyzip", ["~> 0.9.9"]
  s.add_runtime_dependency "htmlentities", ["~> 4.3.1"]
  s.homepage    = 'http://rubygems.org/gems/docx_templater'
end
