$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'restful-sharepoint/version'

Gem::Specification.new 'restful-sharepoint', RestfulSharePoint::VERSION do |s|
  s.summary           = 'Library accessing SharePoint resources via OData REST API'
  s.description       = 'Library accessing SharePoint resources via OData REST API'
  s.authors           = ['Tom Wardrop']
  s.email             = 'tomw@msc.qld.gov.au'
  s.homepage          = ''
  s.license           = 'MIT'
  s.files             = Dir.glob(`git ls-files`.split("\n") - %w[.gitignore])
  s.has_rdoc          = 'yard'

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'httpi', '~> 2.4'
  s.add_dependency 'curb', '~> 0.9'
  s.add_dependency 'require_pattern'
end
