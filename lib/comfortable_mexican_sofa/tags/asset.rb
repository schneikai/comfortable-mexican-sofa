class ComfortableMexicanSofa::Tag::Asset
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:asset:(#{identifier}):?(.*?)\s*\}\}/
  end

  def content
    type    = params[0] || type_from_identifier
    format  = params[1]

    # Rails does not support dots in url id segments so we need to make the
    # identifier url safe.
    safe_identifier = identifier.parameterize

    case type
    when 'css'
      out = "/cms-css/#{blockable.site.id}/#{safe_identifier}/#{blockable.layout.cache_buster}.css"
      out = "<link href='#{out}' media='screen' rel='stylesheet' type='text/css' />" if format == 'html_tag'
      out
    when 'js'
      out = "/cms-js/#{blockable.site.id}/#{safe_identifier}/#{blockable.layout.cache_buster}.js"
      out = "<script src='#{out}' type='text/javascript'></script>" if format == 'html_tag'
      out
    end
  end

  # The asset tag supports to load css or js for a given layout identifier
  # but it also allows to laod any css or js cms file. For this we get the
  # asset type from the filename (aka identifier).
  def type_from_identifier
    identifier.split('.').last.presence
  rescue
    nil
  end
end
