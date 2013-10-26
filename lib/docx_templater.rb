# require 'zip/zipfilesystem'
require 'zip'
require 'htmlentities'
require 'docx/argument_combiner'
require 'docx/document_replacer'
require 'docx/newline_replacer'

# Use .docx as reusable templates
# 
# Example:
# buffer = DocxTemplater.replace_file_with_content('path/to/mydocument.docx',
#    {
#      :client_email1 => 'test@example.com',
#      :client_phone1 => '555-555-5555',
#    })
# # In Rails you can send a word document via send_data
# send_data buffer.string, :filename => 'REPC.docx'
# # Or save the output to a word file
# File.open("path/to/mydocument.docx", "wb") {|f| f.write(buffer.string) }
class DocxTemplater
  def initialize(opts = {})
    @options = opts
  end

  def replace_file_with_content(file_path, data_provider)
    # Rubyzip doesn't save it right unless saved like this: https://gist.github.com/e7d2855435654e1ebc52
    zf = Zip::File.new(file_path) # Put original file name here

    buffer = Zip::OutputStream.write_buffer do |out|
      zf.entries.each do |e|
        process_entry(e, out, data_provider)
      end
    end
    # You can save this buffer or send it with rails via send_data
    return buffer
  end

  def generate_tags_for(*args)
    Docx::ArgumentCombiner.new(*args).attributes
  end

  def entry_requires_replacement?(entry)
    entry.ftype != :directory && entry.name =~ /document|header|footer/
  end

  private
  attr_reader :options

  def get_entry_content(entry, data_provider)
    file_string = entry.get_input_stream.read
    if entry_requires_replacement?(entry)
      replacer = Docx::DocumentReplacer.new(file_string, data_provider, options)
      replacer.replaced
    else
      file_string
    end
  end
  
  def process_entry(entry, output, data_provider)
    output.put_next_entry(entry.name)
    output.write get_entry_content(entry, data_provider) if entry.ftype != :directory
  end
end
