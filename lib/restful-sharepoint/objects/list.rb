module RestfulSharePoint
  class List < Object

    def self.from_title(connection, title)
      new(connection: connection).tap do |list|
        list.define_singleton_method(:endpoint) { "/_api/web/lists/getbytitle('#{URI.encode @id}')" }
      end
    end

    def endpoint
      "/_api/web/lists(guid'#{@id}')"
    end

    def items(options = {})
      query_string = options.map { |k,v| "$#{k}=#{CGI.escape v.to_s}" }.join('&')
      collection = connection.get "#{endpoint}/items?#{query_string}"
      ListItems.new(self, collection)
    end
  end
end
