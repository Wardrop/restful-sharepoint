module RestfulSharePoint
  class File < Object

    def endpoint
      "#{@parent.endpoint}/File"
    end

    def content
      @content ||= connection.get(endpoint)
    end

    # In bytes
    def size
      content.length
    end
  end
end
