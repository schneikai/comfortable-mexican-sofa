class Comfy::Cms::ContentController < Comfy::Cms::BaseController

  # Authentication module must have `authenticate` method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize

  before_action :load_fixtures
  before_action :load_cms_page,
                :authenticate,
                :only => :show

  rescue_from ActiveRecord::RecordNotFound, :with => :page_not_found

  def show
    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url
    else
      respond_to do |format|
        format.all { render_page }
        format.json { render :json => @cms_page }
        format.all { render_page }
      end
    end
  end

  def render_sitemap
    render
  end

protected

  def render_page(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout

      content = Liquid::Template.parse(@cms_page.content_cache).render(liquid_assigns, registers: liquid_registers)

      render  :inline       => content,
              :layout       => app_layout,
              :status       => status,
              :content_type => mime_type
    else
      render :text => I18n.t('comfy.cms.content.layout_not_found'), :status => 404
    end
  end

  # Returns a Hash of available variables, objects or drops that the template
  # can reference. You can create a method +cms_assigns_for+ in you apps
  # application controller to customize the Hash. You can even return
  # custom assigns for different sites, layouts or pages. For example:
  #
  #   def cms_assigns_for(site, layout, page)
  #     defaults = { 'customer' => current_user }
  #     extras = { 'basket' => basket } if layout.identifier == 'shop'
  #     defaults.merge(extras || {})
  #   end
  #
  def liquid_assigns
    if respond_to?(:cms_assigns_for)
      custom_assigns = cms_assigns_for(@cms_site, @cms_layout, @cms_page)
    end

    {
      'site' => @cms_site.to_liquid,
      'page' => @cms_page.to_liquid
    }.merge(custom_assigns || {})
  end

  # Returns a Hash with register variables that can be accessed from Liquid
  # filters and tags.
  # Remember: Use assigns if you want to exposed something to just the page or
  # layout and use registers only within the back-end processing of the template.
  def liquid_registers
    {
      controller: self,
      view: self.view_context
    }
  end

  # it's possible to control mimetype of a page by creating a `mime_type` field
  def mime_type
    mime_block = @cms_page.blocks.find_by_identifier(:mime_type)
    mime_block && mime_block.content || 'text/html'
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixture::Importer.new(@cms_site.identifier).import!
  end

  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
  end

  def page_not_found
    @cms_page = @cms_site.pages.published.find_by_full_path!('/404')

    respond_to do |format|
      format.html { render_page(404) }
    end
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Page Not Found at: \"#{params[:cms_path]}\"")
  end
end
