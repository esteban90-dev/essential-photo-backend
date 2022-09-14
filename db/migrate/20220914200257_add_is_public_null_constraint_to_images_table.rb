class AddIsPublicNullConstraintToImagesTable < ActiveRecord::Migration[6.1]
  def up
    change_column :images, :is_public, :boolean, null: false
  end

  def down
    change_column :images, :is_public, :boolean, null: true
  end
end
