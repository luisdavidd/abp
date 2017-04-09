class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.integer :user_to, null: false
      t.float :amount, null: false
      t.text :observations

      t.timestamps
    end
  end
end
