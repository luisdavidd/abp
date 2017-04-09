class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :offer, foreign_key: true
      t.references :user, foreign_key: true
      t.text :content, null: false
      t.float :price_offer, null: false

      t.timestamps
    end
  end
end
