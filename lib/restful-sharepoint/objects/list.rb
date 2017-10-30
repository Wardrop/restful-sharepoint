module RestfulSharePoint
  class List < Object

    def self.from_title(connection, title)
      new(connection: connection).tap do |list|
        list.define_singleton_method(:endpoint) { "/_api/web/lists/getbytitle('#{URI.encode title}')" }
      end
    end

    def endpoint
      "/_api/web/lists(guid'#{@id}')"
    end
  end
end
