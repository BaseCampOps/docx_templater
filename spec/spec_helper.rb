require 'bundler/setup'
require 'docx_templater'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end

def get_header_string(file_path)
  unzipped = Zip::File.new(file_path)
  entries = unzipped.entries.select do |e| e.name =~ /word\/header/ end
  entries.inject("") do |str, e| str << e.get_input_stream.read end
end

def get_footer_string(file_path)
  unzipped = Zip::File.new(file_path)
  entries = unzipped.entries.select do |e| e.name =~ /word\/footer/ end
  entries.inject("") do |str, e| str << e.get_input_stream.read end
end

def get_body_string(file_path)
  unzipped = Zip::File.new(file_path)
  entries = unzipped.entries.select do |e| e.name =~ /word\/document/ end
  entries.inject("") do |str, e| str << e.get_input_stream.read end
end
  
