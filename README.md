Provides a convenient object model to the OData REST API of SharePoint 2013 and newer.

No unit tests as of yet.

Examples
--------
``` ruby
require 'restful-sharepoint'
connection = RestfulSharePoint::Connection.new('http://sharepoint/mysite/', 'username', 'password')
list = RestfulSharePoint::List.from_title('My List', connection)
list_item = list.Items[0] # Dynamically invoke the deferred "Items" element
first_attachment = list_item.AttachmentFiles[0].content

list_item.values # Return the raw tree structure
```
