class CreateOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :offers do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.integer :quantity, default: 1
      t.float :price, default: 0, null: false
      t.datetime :due_date, null: false

      t.timestamps
    end
  end
end
