require 'rexml/document'
module Docx
  class PlaceholderObserver
    attr_reader :data_provider
    def initialize(data_provider)
      @data_provider = data_provider
      @buffer = ''
      @state = :waiting_for_opening
    end

    def next_node(node)
      node.value.each_char do |c|
        next_char(c)
      end
    end
    private
    attr_accessor :state, :buffer
    def next_char(c)
      send(state, c)
    end

    def waiting_for_opening(c)
      if c == '|'
        buffer << c
        if buffer == '||'
          self.state = :capturing_placeholder
        end
      else
        buffer = ''
      end
    end

    def capturing_placeholder(c)
      buffer << c
      if buffer[-2..-1] == '||'
        key = buffer[2..-3]
        new_value = data_provider[key]
        self.state = :waiting_for_opening
      end
    end
  end
end
