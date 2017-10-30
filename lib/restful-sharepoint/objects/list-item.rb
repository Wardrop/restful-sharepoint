module RestfulSharePoint
  class ListItem < Object

    def endpoint
      "#{@parent.endpoint}/Items(#{@id})"
    end

  end
end
