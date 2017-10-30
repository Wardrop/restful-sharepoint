module RestfulSharePoint
  class Attachment < File

    def endpoint
      url = URI.parse(connection.site_url)
      url.path = URI.encode(@properties['ServerRelativeUrl'])
      url.to_s
    end
  end
end
