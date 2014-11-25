# The CMS Site wraped as a Liquid template parameter object (aka Drop).
# https://github.com/Shopify/liquid/wiki/Introduction-to-Drops

class Comfy::Cms::Drops::SiteDrop < Liquid::Drop
  def initialize(site)
    @site = site
  end

  def label
    @site.label
  end

  def identifier
    @site.identifier
  end

  def hostname
    @site.hostname
  end

  def path
    @site.path
  end

  def locale
    @site.locale
  end
end
