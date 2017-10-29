module RestfulSharePoint
  class Error < RuntimeError; end
  class RestError < Error; end
  class FileNotFound < Error; end
end
