class Comfy::Cms::File < ActiveRecord::Base
  self.table_name = 'comfy_cms_files'

  IMAGE_MIMETYPES = %w(gif jpeg pjpeg png tiff).collect{|subtype| "image/#{subtype}"}

  cms_is_categorized

  attr_accessor :dimensions, :tags

  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options.merge(
    # dimensions accessor needs to be set before file assignment for this to work
    :styles => lambda { |f|
      if f.respond_to?(:instance) && f.instance.respond_to?(:dimensions)
        (f.instance.dimensions.blank?? { } : { :original => f.instance.dimensions }).merge(
          :cms_thumb => '100x75#'
        ).merge(ComfortableMexicanSofa.config.upload_file_options[:styles] || {})
      end
    }
  )
  before_post_process :is_image?

  delegate :url, to: :file # so we don't need to write confusing file.file.url

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :block

  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates_attachment_presence :file
  do_not_validate_attachment_file_type :file

  validates :file_file_name,
    :uniqueness => {:scope => [:site_id, :block_id]}

  # -- Callbacks ------------------------------------------------------------
  before_save   :assign_label
  before_create :assign_position
  after_save    :reload_blockable_cache
  after_destroy :reload_blockable_cache
  before_save   :clear_content_cache

  # -- Scopes ---------------------------------------------------------------
  scope :not_page_file, -> { where(:block_id => nil)}
  scope :images,        -> { where(:file_content_type => IMAGE_MIMETYPES) }
  scope :not_images,    -> { where('file_content_type NOT IN (?)', IMAGE_MIMETYPES) }

  # -- Instance Methods -----------------------------------------------------
  def is_image?
    IMAGE_MIMETYPES.include?(file_content_type)
  end

  # Returns the file as a stream.
  def stream
    # If *file.url* returns a relative url that means that the file is stored
    # on the local file system and we need to use *file.path* which returns a
    # absolute path to open the file.
    location = (file.url =~ /^[\w]*:\/\//).nil? ? file.path : file.url
    open(location) { |f| f.read }
  rescue
    raise ActiveRecord::RecordNotFound, "Couldn't find attached file in #{file.url} for #{self.class.name} with id=#{id}"
  end

  # Returns the file content with all cms tags processed.
  def render
    @tags = []
    ComfortableMexicanSofa::Tag.process_content(
      self, ComfortableMexicanSofa::Tag.sanitize_irb(stream)
    )
  end

  # Cached content accessor
  def content_cache
    if (@content_cache = read_attribute(:content_cache)).nil?
      @content_cache = self.render
      update_column(:content_cache, @content_cache) unless self.new_record?
    end
    @content_cache
  end

  def clear_content_cache!
    self.update_column(:content_cache, nil)
  end

  def clear_content_cache
    write_attribute(:content_cache, nil) if self.has_attribute?(:content_cache)
  end

protected

  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end

  def assign_position
    max = Comfy::Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def reload_blockable_cache
    return unless self.block
    b = self.block.blockable
    b.class.name.constantize.where(:id => b.id).update_all(:content_cache => nil)
  end

end
