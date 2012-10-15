require 'zip/zipfilesystem'

class WordTemplater

  # Use .docx as reusable templates
  # 
  # Example:
  # buffer = WordTemplater.replace_file_with_content('path/to/mydocument.docx',
  #    {
  #      :client_email1 => 'test@example.com',
  #      :client_phone1 => '555-555-5555',
  #    })
  # # In Rails you can send a word document via send_data
  # send_data buffer.string, :filename => 'REPC.docx'
  # # Or save the output to a word file
  # File.open("path/to/mydocument.docx", "wb") {|f| f.write(buffer.string) }

  def self.available_tags
    {
      :example1 => '943 E Sunset Ave',
      :example_address2 => 'Apt #4'
    }
  end
  
  def self.all_tags_regex
    /\|\|\<*.+?\>*\|\|/
  end
  
  def self.malformed_tag_regex
    /(?<=>)\w{3,}(?=<)/
  end
  
  def self.well_formed_tag_regex
    /(?<=\|\|)\w{3,}(?=\|\|)/
  end
  
  def self.just_label_regex
    /(?<=>)(\w{3,})/
  end
  
  # Can pass in the same arguments here for available_tags as in the params for generate_tags_for
  def self.replace_file_with_content(file_path, *available_tags)
    # Rubyzip doesn't save it right unless saved like this: https://gist.github.com/e7d2855435654e1ebc52
    zf = Zip::ZipFile.new(file_path) # Put original file name here
    
    available_tags ||= self.available_tags
    if available_tags.is_a?(Array)
      available_tags = self.generate_tags_for(available_tags)
    end
    buffer = Zip::ZipOutputStream.write_buffer do |out|
      zf.entries.each do |e|
        if e.ftype == :directory
          out.put_next_entry(e.name)
        else
          file_content = e.get_input_stream.read
          out.put_next_entry(e.name)
          # If this is the xml file with actual content
          if e.name == 'word/document.xml' || e.name.include?('header') || e.name.include?('footer')
            possible_tags = file_content.scan(all_tags_regex)
            # Loops through what looks like are tags. Anything with ||name|| even if they are not in the available tags list
            possible_tags.each do |tag|
              #extracts just the tag name
              tag_name = self.malformed_tag_regex.match(tag)
              tag_name ||= self.well_formed_tag_regex.match(tag)
              tag_name ||= ''
              # This will handle instances where someone edits just part of a tag and Word wraps that part in more XML
              words = tag.scan(self.just_label_regex).flatten!
              if words.respond_to?(:size) && words.size > 1
                #Then the tag was split by word
                tag_name = words.join('')
              end
              tag_name = tag_name.to_s.to_sym
              # if in the available tag list, replace with the new value
              if available_tags.has_key?(tag_name)
                file_content.gsub!(tag, "#{available_tags[tag_name]}")
              end
            end
          end
          out.write file_content
        end
      end
    end
    # You can save this buffer or send it with rails via send_data
    return buffer
  end
  
  # Pass in records and this will return a list of available tags for all of the models
  # Can also pass in a non mongoid record such as a hash and it will be automatically merged into the tags hash
  # Can also include a Hash with :data => Mongoid record, :prefix => 'custom_prefix'
  # Example WordTemplater.generate_tags_for(@deal.property, {:client_first_name => 'Paul'}, {:data => @deal.user, :prefix => 'client'}))
  def self.generate_tags_for(*args)
    attributes = {}
    args.flatten!
    # Prefixes the model name or custom prefix. Makes it so we don't having naming clashes when used with records from multiple models
    args.each do |arg|
      if arg.is_a?(Hash) && arg.has_key?(:data) && arg.has_key?(:prefix)
        template_attributes = (arg[:data].respond_to?(:template_attributes) && :template_attributes) || :attributes
        arg[:data].send(template_attributes).each_key do |key|
          attributes["#{arg[:prefix]}_#{key.to_s}".to_sym] = arg[:data].send(template_attributes)[key]
        end
      elsif arg.is_a?(Hash)
        attributes.merge!(arg)
      else
        template_attributes = (arg.respond_to?(:template_attributes) && :template_attributes) || :attributes
        arg.send(template_attributes).each_key do |key|
          attributes["#{arg.class.name.underscore}_#{key.to_s}".to_sym] = arg.send(template_attributes)[key]
        end
      end
    end
    attributes
  end
  
end


#buffer = WordTemplater.replace_file_with_content('./REPC.docx')
# Saves it to a file, but could easily just be sent to the browser without touching the file system
#File.open("latest.docx", "wb") {|f| f.write(buffer.string) }


