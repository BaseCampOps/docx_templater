require 'rexml/document'
require 'docx/placeholder_observer'
module Docx
	class DocumentReplacer
    attr_reader :doc, :observer
    def initialize(str, data_provider)
      @doc = REXML::Document.new(str)
      @observer = Docx::PlaceholderObserver.new(data_provider)
      walk_node(@doc.root)
    end

    def replaced
      @doc.to_s
    end

    private
    def walk_node(node)
      if node.is_a?(REXML::Element)
        node.children.each do |n|
          walk_node(n)
        end
      elsif node.is_a?(REXML::Text)
        observer.next_node(node)
      end
    end
	end
end
