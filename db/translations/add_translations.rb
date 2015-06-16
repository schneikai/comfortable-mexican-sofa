class AddTranslations < ActiveRecord::Migration

  def self.up

    text_limit = case ActiveRecord::Base.connection.adapter_name
                   when 'PostgreSQL'
                     {}
                   else
                     {:limit => 16777215}
                 end

    create_table :comfy_cms_translations do |t|
      t.references :translateable, :polymorphic => true
      t.string :locale, :null => false
      t.integer :target_page_id
      t.string :label, :null => false
      t.string :slug
      t.string :full_path, :null => false
      t.text :content_cache, text_limit
      t.boolean :is_published, :null => false, :default => true
      t.timestamps
    end
    add_index :comfy_cms_translations, [:full_path]
    add_index :comfy_cms_translations, [:translateable_id, :translateable_type],
              :name => 'index_cms_translations_on_tid_and_ttype'
  end

  def self.down
    drop_table :comfy_cms_translations
  end
end

