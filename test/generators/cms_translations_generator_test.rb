require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/translations_generator'

class CmsGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::Cms::TranslationsGenerator

  def test_generator
    run_generator

    assert_migration 'db/migrate/add_cms_translations.rb'
  end
end