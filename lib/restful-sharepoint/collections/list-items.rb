module RestfulSharePoint
  class ListItems < Collection

    def self.object_class
      ListItem
    end

    def endpoint
      "#{@parent.endpoint}/Items"
    end

  end
end
