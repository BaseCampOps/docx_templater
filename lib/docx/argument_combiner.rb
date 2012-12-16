module Docx
  class ArgumentCombiner
    attr_reader :attributes
    def initialize(*args)
      @attributes = {}
      args.flatten!
      # Prefixes the model name or custom prefix. Makes it so we don't having naming clashes when used with records from multiple m
      args.each do |arg|
        if arg.is_a?(Hash) && arg.has_key?(:data) && arg.has_key?(:prefix)
          template_attributes = (arg[:data].respond_to?(:template_attributes) && :template_attributes) || :attributes
          arg[:data].send(template_attributes).each_key do |key|
            @attributes["#{arg[:prefix]}_#{key.to_s}".to_sym] = arg[:data].send(template_attributes)[key]
          end
        elsif arg.is_a?(Hash)
          @attributes.merge!(arg)
        else
          template_attributes = (arg.respond_to?(:template_attributes) && :template_attributes) || :attributes
          arg.send(template_attributes).each_key do |key|
            @attributes["#{arg.class.name.underscore}_#{key.to_s}".to_sym] = arg.send(template_attributes)[key]
          end
        end
      end
    end
  end
end
