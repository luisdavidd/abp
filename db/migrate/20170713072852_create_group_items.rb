class CreateGroupItems < ActiveRecord::Migration[5.0]
  def change
    create_table :group_items do |t|
      t.integer :group_id
      t.integer :product_id
      t.integer :product_type

      t.timestamps
    end
  end
end
