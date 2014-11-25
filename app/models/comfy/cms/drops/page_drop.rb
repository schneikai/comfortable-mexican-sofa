# The CMS Page wraped as a Liquid template parameter object (aka Drop).
# https://github.com/Shopify/liquid/wiki/Introduction-to-Drops

class Comfy::Cms::Drops::PageDrop < Liquid::Drop
  def initialize(page)
    @page = page
  end

  def label
    @page.label
  end

  def slug
    @page.slug
  end

  def full_path
    @page.full_path
  end

  def created_at
    @page.created_at
  end

  def updated_at
    @page.updated_at
  end

  def site
    @page.site.to_liquid
  end

  def parent
    @page.parent.to_liquid
  end

  def children
    @page.children.map do |child|
      child.to_liquid
    end
  end

  def target
    @page.target_page.to_liquid
  end
end
