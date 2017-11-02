module RestfulSharePoint
  class File < Object

    def endpoint
      "#{@parent.endpoint}/File"
    end

    def content
      @content ||= connection.get(url)
    end

    def url
      url = URI.parse(connection.site_url)
      url.path = URI.encode(self['ServerRelativeUrl'])
      url.to_s
    end

    # In bytes
    def size
      self['Length'] || content.length
    end

    def name
      filename.rpartition('.').first
    end

    def filename
      self['ServerRelativeUrl'].rpartition('/').last
    end

    def extension
      self['ServerRelativeUrl'].rpartition('.').last
    end
  end
end
