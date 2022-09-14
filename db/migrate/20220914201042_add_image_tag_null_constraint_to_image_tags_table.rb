class AddImageTagNullConstraintToImageTagsTable < ActiveRecord::Migration[6.1]
  def up
    change_column :image_tags, :image_id, :bigint, null: false
    change_column :image_tags, :tag_id, :bigint, null: false
  end

  def down
    change_column :image_tags, :image_id, :bigint, null: true
    change_column :image_tags, :tag_id, :bigint, null: true
  end
end
