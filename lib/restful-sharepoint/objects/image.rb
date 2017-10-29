module RestfulSharePoint
  class File < Object
    # Overwrite can be true, false, or a date.
    def save_thumbnail(dest, size: '128x128', format: 'jpg', overwrite: true)
      if !::File.exist?(dest) || overwrite == true || (Time === overwrite && ::File.mtime(dest) < overwrite)
        image = MiniMagick::Image.read(content).collapse!
        image.combine_options do |img|
          img.thumbnail "#{size}^"
          img.gravity "center"
          img.colorspace "sRGB"
          img.background "white"
          img.flatten # Merges images with white background
        end
        image.format format
        image.write dest
      end
    end
  end
end
