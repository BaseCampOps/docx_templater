require 'rexml/document'
require 'docx/nodes_to_fix'
module Docx
  class PlaceholderObserver
    attr_reader :data_provider
    def initialize(data_provider)
      @data_provider = data_provider
      @buffer = ''
      @state = :waiting_for_opening
      @nodes_to_fix = NodesToFix.new
      @fixes_to_make = []
    end

    def next_node(node)
      node.value.split(//).each_with_index do |c,index|
        next_char(node,index,c)
      end
    end

    def end_of_document
      make_fixes
    end

    private

    attr_accessor :state, :buffer, :nodes_to_fix

    def next_char(node, index, c)
      send(state, node, index, c)
    end

    def waiting_for_opening(node, index, c)
      if c == '|'
        add_char_to_buffer(node,index,c)
        if buffer == '||'
          self.state = :capturing_placeholder
        end
      else
        truncate_buffer
      end
    end

    def capturing_placeholder(node, index, c)
      add_char_to_buffer(node,index,c)
      if buffer[-2..-1] == '||'
        key = buffer[2..-3]
        if data_provider.has_key?(key.to_sym)
          new_value = data_provider[key.to_sym]
          save_fix_for_later(new_value)
        end
        self.state = :waiting_for_opening
        truncate_buffer
      end
    end

    def add_char_to_buffer(node, index, c)
      @nodes_to_fix.remember(node,index)
      @buffer << c
    end

    def truncate_buffer
      @buffer = ''
      @nodes_to_fix.forget
    end

    def save_fix_for_later(val)
      @nodes_to_fix.value = val
      @fixes_to_make << @nodes_to_fix
      @nodes_to_fix = NodesToFix.new
    end

    def make_fixes
      @fixes_to_make.reverse.each do |nodes_to_fix|
        nodes_to_fix.fix
      end
      @fixes_to_make = []
    end
  end
end
