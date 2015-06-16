require 'rails/generators/active_record'

module Comfy
  module Generators
    module Cms
      class TranslationsGenerator < Rails::Generators::Base

        include Rails::Generators::Migration
        include Thor::Actions

        source_root File.expand_path('../../../../..', __FILE__)

        def generate_migration
          destination = File.expand_path('db/translations/add_translations.rb', self.destination_root)
          migration_dir = File.dirname(destination)
          destination = self.class.migration_exists?(migration_dir, 'add_cms_translations')

          if destination
            puts "\e[0m\e[31mFound existing add_cms_translations.rb migration. Remove it if you want to regenerate.\e[0m"
          else
            migration_template 'db/translations/add_translations.rb', 'db/migrate/add_cms_translations.rb'
          end
        end

        def self.next_migration_number(dirname)
          ActiveRecord::Generators::Base.next_migration_number(dirname)
        end

      end
    end
  end
end