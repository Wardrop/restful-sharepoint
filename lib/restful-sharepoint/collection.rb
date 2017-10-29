module RestfulSharePoint
  class Collection
    def self.object_class
      Object
    end

    def initialize(parent: nil, connection: nil, collection: nil)
      @parent = parent.connection
      @connection = connection || @parent.connection # Iterate collection and coerce each into into a ListItem
      @collection = collection
    end

    def objects
      @objects ||= @collection['results'].map { |item| self.class.object_class.new(@list, item) }
    end

    def next
      self.new(@connection, @connection.get(@collection['__next']))
    end

    def method_missing(method, *args)
      objects.respond_to?(method) ? objects.send(method, *args) : super
    end

    def respond_to_missing?(method, include_all = false)
      objects.respond_to?(method, include_all)
    end
  end
end
