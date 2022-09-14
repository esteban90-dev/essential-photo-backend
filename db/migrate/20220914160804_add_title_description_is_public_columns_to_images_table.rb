class AddTitleDescriptionIsPublicColumnsToImagesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :title, :string
    add_column :images, :description, :text
    add_column :images, :is_public, :boolean
  end
end
