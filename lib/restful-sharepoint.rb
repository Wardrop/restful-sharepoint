require 'json'
require 'httpi'
require 'curb'
require 'cgi'
require 'require_pattern'

HTTPI.adapter = :curb

require_relative_pattern './restful-sharepoint/*.rb'
require_relative_pattern './restful-sharepoint/*/*.rb'
