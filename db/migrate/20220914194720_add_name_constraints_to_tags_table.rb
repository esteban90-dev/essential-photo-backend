class AddNameConstraintsToTagsTable < ActiveRecord::Migration[6.1]
  def up
    change_column :tags, :name, :string, null: false
    add_index :tags, :name, unique: true
  end

  def down
    change_column :tags, :name, :string, null: true
    remove_index :tags, :name, unique: true
  end
end
