require 'date'
require 'uri'

module RestfulSharePoint
  class Connection
    def initialize(site_url, username = nil, password = nil)
      @site_url = site_url
      @username = username
      @password = password
    end

    attr_reader :site_url

    def get(path, options: {})
      request path, :get, options: options
    end

    # Path can be either relative to the site URL, or a complete URL itself.
    # Takes an optional `options` hash which are any number of valid OData query options (dollar sign prefix is added automatically)
    # Also takes an optional block that is provided the HTTPI::Request instance, allowing customisation of the request.
    def request(path, method, options: {}, body: nil)
      url = URI.parse(path).is_a?(URI::HTTP) ? path : "#{@site_url}#{path}"
      options_str = options.map { |k,v| "$#{k}=#{CGI.escape v.to_s}" }.join('&')
      url += "?#{options_str}"
      req = HTTPI::Request.new(url: url, headers: {'accept' => 'application/json; odata=verbose'})
      req.auth.ntlm(@username, @password) if @username
      if body
        req.body = body.to_json.gsub('/', '\\/') # SharePoint requires forward slashes be escaped in JSON (WTF!!!)
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-HTTP-Method'] = 'MERGE' # TODO: Extend logic to support all operations
        req.headers['If-Match'] = '*'
      end
      yield(request) if block_given?
      response = HTTPI.request(method, req)
      if response.body.empty?
        if response.code >= 300
          raise RestError, "Server returned HTTP status #{response.code} with no message body."
        end
      else
        if response.headers['Content-Type'].start_with? "application/json"
          data_tree = parse(response.body)
        else
          response.body
        end
      end
    end

  protected

    def parse(str)
      data = JSON.parse(str)
      raise RestError, "(#{data['error']['code']}): #{data['error']['message']['value']}" if data['error']
      parse_tree(data['d'])
    end

    def parse_tree(tree)
      indices = tree.respond_to?(:keys) ? tree.keys : 0...tree.length
      indices.each do |i|
        if tree[i].respond_to?(:=~) && tree[i] =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$/
          tree[i] = DateTime.parse(tree[i]).new_offset(DateTime.now.offset)
        elsif tree[i].respond_to?(:gsub!)
          # Convert relative paths to absolute URL's.
          tree[i].gsub!(/((?<=href=)|(?<=src=))['"](\/.+?)['"]/, %Q("#{@site_url}\\2\"))
        elsif tree[i].is_a? Enumerable
          parse_tree(tree[i])
        end
      end
      tree
    end

  end
end
