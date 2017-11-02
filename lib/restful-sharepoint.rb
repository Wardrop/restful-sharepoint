require 'json'
require 'httpi'
require 'curb'
require 'cgi'
require 'require_pattern'

HTTPI.adapter = :curb

module RestfulSharePoint
  OBJECT_MAP = {
    "SP.Web" => :Web,
    "SP.List" => :List,
    /SP\.Data\..*Item/ => :ListItem,
    "SP.File" => :File,
    "SP.Attachment" => :Attachment
  }

  COLLECTION_MAP = {
    "SP.Web" => :Webs,
    "SP.List" => :Lists,
    /SP\.Data\..*Item/ => :ListItems,
    "SP.Attachment" => :Attachments
  }
end

require_relative './restful-sharepoint/version.rb'
require_relative './restful-sharepoint/error.rb'
require_relative './restful-sharepoint/connection.rb'
require_relative './restful-sharepoint/common-base.rb'
require_relative './restful-sharepoint/object.rb'
require_relative './restful-sharepoint/collection.rb'
require_relative_pattern './restful-sharepoint/*/*.rb'
