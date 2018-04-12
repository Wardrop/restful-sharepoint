require 'oj'
require 'httpi'
require 'curb'
require 'cgi'
require 'logger'

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

  LOG = Logger.new('restful-sharepoint.log')
end

require_relative './restful-sharepoint/version.rb'
require_relative './restful-sharepoint/error.rb'
require_relative './restful-sharepoint/connection.rb'
require_relative './restful-sharepoint/common-base.rb'
require_relative './restful-sharepoint/object.rb'
require_relative './restful-sharepoint/collection.rb'

require_relative './restful-sharepoint/objects/file.rb'
require_relative './restful-sharepoint/objects/attachment.rb'
require_relative './restful-sharepoint/objects/list-item.rb'
require_relative './restful-sharepoint/objects/list.rb'
require_relative './restful-sharepoint/objects/web.rb'

require_relative './restful-sharepoint/collections/attachments.rb'
require_relative './restful-sharepoint/collections/list-items.rb'
require_relative './restful-sharepoint/collections/lists.rb'
require_relative './restful-sharepoint/collections/webs.rb'
