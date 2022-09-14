class CreateImagesTagsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :images_tags_tables do |t|
      t.references :image
      t.references :tag

      t.timestamps
    end
  end
end
