module RestfulSharePoint
  class ListItem < Object

    def endpoint
      "#{parent.endpoint}/Items(#{@id})"
    end

    def files
      # get files
    end

  end
end
