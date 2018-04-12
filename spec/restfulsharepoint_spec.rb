ENV['RUBY_ENV'] = 'production'

require 'yaml'
require_relative '../lib/restful-sharepoint.rb'

CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))

module RestfulSharePoint
  describe RestfulSharePoint do
    let :c do
      Connection.new(CONFIG[:site_url], CONFIG[:username], CONFIG[:password])
    end

    it "can establish a connection" do
      lists = c.get('/_api/web/lists/')
      expect(lists).to be_a(Hash)
      expect(lists['results']).to be_a(Array)
    end

    it "can work with a collection" do
      lists = Collection.new(connection: c, collection: c.get('/_api/web/lists/')['results'])
      expect(lists.map { |v| v['Title'] }).to include(CONFIG[:test_list_title])
    end

    it "can work with an object" do
      list = Object.new(connection: c, properties: c.get("/_api/web/lists/getbytitle('#{URI.encode CONFIG[:test_list_title]}')"))
      expect(list['Title']).to eq(CONFIG[:test_list_title])
    end

    it "can automatically get an object or collection" do
      lists = c.get_as_object('/_api/web/lists/')
      list = c.get_as_object("/_api/web/lists/getbytitle('#{URI.encode CONFIG[:test_list_title]}')")
      expect(lists).to be_a(Collection)
      expect(list).to be_a(Object)
    end

    it "can get a list by title" do
      list = List.from_title(CONFIG[:test_list_title], c)
      expect(list['Title']).to eq(CONFIG[:test_list_title])
    end

    it "can automatically retrieve deferred objects and c
    ollections" do
      list = List.from_title(CONFIG[:test_list_title], c)
      expect(list['Items'][0]['ContentType']['Name']).to be_a(String)
    end

    it "can give options when retrieving deferred objects" do
      list = List.from_title(CONFIG[:test_list_title], c)
      expect(list['Items'].to_a[0]['ContentType']['Name']).to be_nil
      expect{list['Items', {expand: 'ContentType'}]}.to output.to_stderr # Should warn about deferred object already been fetched
      list2 = List.from_title(CONFIG[:test_list_title], c)
      expect(list2['Items', {expand: 'ContentType'}].to_a[0]['ContentType']['Name']).to be_a(String)
    end
  end
end
