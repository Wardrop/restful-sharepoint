module RestfulSharePoint
  class Attachments < Collection

    def self.object_class
      Attachment
    end

    def endpoint
      "#{@parent.endpoint}/AttachmentFiles"
    end

  end
end
