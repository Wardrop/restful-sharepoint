module RestfulSharePoint
  class Object < CommonBase
    DEFAULT_OPTIONS = {}

    def initialize(parent: nil, connection: nil, properties: nil, id: nil, options: {})
      raise Error, "Either a parent or connection must be provided." unless parent || connection
      @parent = parent
      @connection = connection || @parent.connection
      self.properties = properties
      @id = id
      self.options = options
    end

    attr_accessor :connection
    attr_reader :options
    def options=(options)
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    attr_writer :endpoint
    def endpoint

    end

    def properties=(properties)
      @properties = properties
      @properties&.each do |k,v|
        if v.respond_to?(:keys) && v['__deferred']
          define_singleton_method(k) do |options = {}|
            if Hash === properties[k] && properties[k]['__deferred']
              fetch_deferred(k, options)
            else
              warn("`options` have been ignored as `#{k}` has already been loaded") unless options.empty?
              properties[k]
            end
          end
        elsif v.respond_to?(:keys) && (v['__metadata'] || v['results'])
          @properties[k] = objectify(v)
        end
      end
      @properties
    end

    def properties
      @properties || self.properties = connection.get(endpoint, options: @options)
    end

    def values
      properties.dup.each { |k,v| properties[k] = v.values if v.is_a?(Object) || v.is_a?(Collection) }
    end

    def fetch_deferred(property, options = {})
      data = connection.get(@properties[property]['__deferred']['uri'], options: options)
      @properties[property] = objectify(data)
    end

    def to_json(*args, &block)
      properties.to_json(*args, &block)
    end

    def method_missing(method, *args, &block)
      if properties.respond_to?(method)
        properties.send(method, *args, &block)
      elsif self.methods(false).include?(method) # Works around lazily loaded `properties`
        self.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_all = false)
      properties.respond_to?(method, include_all)
    end

  end
end
