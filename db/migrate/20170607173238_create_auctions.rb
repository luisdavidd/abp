class CreateAuctions < ActiveRecord::Migration[5.0]
  def change
    create_table :auctions do |t|
      t.string :name 
      t.references :user, foreign_key: true
      t.integer :auctioneers_number, default: 1000
      t.float :price, default: 0, null: false
      t.datetime :due_date, null: false
      t.integer :nrc, null: false
      t.string :auction_type, default: 'good'
      t.integer :winner
      t.timestamps
    end
  end
end