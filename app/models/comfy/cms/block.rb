class Comfy::Cms::Block < ActiveRecord::Base
  self.table_name = 'comfy_cms_blocks'

  # -- Relationships --------------------------------------------------------
  belongs_to :blockable,
    :polymorphic  => true
  has_many :files,
    :autosave   => true,
    :dependent  => :destroy

  # -- Validations ----------------------------------------------------------
  validates :identifier,
    :presence   => true,
    :uniqueness => { :scope => [:blockable_type, :blockable_id] }

  # -- Callbacks ------------------------------------------------------------
  before_save :remove_existing_files

  # -- Instance Methods -----------------------------------------------------
  # Tag object that is using this block
  def tag
    @tag ||= blockable.tags(:reload).detect{|t| t.is_cms_block? && t.identifier == identifier}
  end

protected

  # Back in the days the PageFile tag allowed to upload files. This was changed
  # to just select a file from the library. So we need to delete old uploaded
  # files here if the tag content was changed.
  def remove_existing_files
    return unless self.files.any? && self.tag.instance_of?(ComfortableMexicanSofa::Tag::PageFile)
    self.files.collect{ |f| f.mark_for_destruction } if self.tag.serialize_content != content
  end
end
