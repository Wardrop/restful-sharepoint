module RestfulSharePoint
  class Attachment < File

    def endpoint
      @properties['ServerRelativeUrl']
    end
  end
end
