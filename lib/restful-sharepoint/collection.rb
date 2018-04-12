module RestfulSharePoint
  class Collection < CommonBase
    DEFAULT_OPTIONS = {}

    include Enumerable
    extend Forwardable

    def_delegators :@collection, :each, :length, :[]

    def self.object_class
      Object
    end

    def initialize(parent: nil, connection: nil, collection: nil, options: {})
      @parent = parent
      @connection = @parent ? @parent.connection : connection
      self.collection = collection
      self.options = options
    end

    attr_accessor :connection

    attr_reader :options
    def options=(options)
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    attr_writer :endpoint
    def endpoint
      @endpoint || (raise NotImplementedError, "Endpoint could not be determined")
    end

    def collection=(collection)
      @collection = collection
      @collection&.each_with_index do |v,i|
        @collection[i] = connection.objectify(v)
      end
      @collection
    end

    def ==(other)
      other.== collection
    end

    def eql?(other)
      other.eql? collection
    end

    def collection
      @collection || self.collection = connection.get(endpoint, options: @options)
    end

    def to_a
      collection.map do |v|
        case v
        when Object
          v.to_h
        when Collection
          v.to_a
        else
          v
        end
      end
    end
    alias to_array to_a

    def next
      self.new(@connection, @connection.get(collection['__next']))
    end

    def to_json(*args, &block)
      collection.to_json(*args, &block)
    end
  end
end
