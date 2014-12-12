class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag

  # Signature of a tag:
  #   {{ cms:page_file:some_label:type:params }}
  # Simple tag can be:
  #   {{ cms:page_file:some_label }}
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page_file:(#{identifier}):?(.*?)\s*\}\}/
  end

  # Type of the tag controls how file is rendered
  def type
    s = params[0].to_s.gsub(/\[.*?\]/, '')
    %w(partial url image link field).member?(s) ? s : 'url'
  end

  # TODO: This won't work anymore because the tag just allows to select a file
  # from the library. Would be nice to have image resize/crop in the library though.
  def dimensions
    params[0].to_s.match(/\[(.*?)\]/)[1] rescue nil
  end

  def content
    # The PageFile tag was changed from uploading files to just saving a reference
    # to a file in the files library. For backwards compatibility we return the
    # uploaded file if one exists.
    if block.files.any?
      @content ||= block.files.first
    else
      @content ||= Comfy::Cms::File.where(id: block.content).first
    end
  end

  # For form inputs.
  def serialize_content
    content.id.to_s if content.respond_to?(:id)
  end

  def render
    case self.type
      when 'url'      then render_url(content)
      when 'link'     then render_link(content)
      when 'image'    then render_image(content)
      when 'partial'  then render_partial(content)
      else ''
    end
  end

  def render_url(file)
    return '' unless file
    file.file.url
  end

  def render_link(file)
    return '' unless file
    text = params[1] || identifier
    "<a href='#{file.file.url}' target='_blank'>#{text}</a>"
  end

  def render_image(file)
    return '' unless file
    text = params[1] || file.label
    "<img src='#{file.file.url}' alt='#{text}' />"
  end

  def render_partial(file)
    path = params[1] || 'partials/page_file'
    ps = (self.params[2..-1] || []).collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
    ps = ps.present?? ", #{ps}" : ''
    "<%= render :partial => '#{path}', :locals => {:identifier => #{file.try(:id) || 'nil'}#{ps}} %>"
  end

end
