class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.integer :user_id
      t.string :elemento
      t.integer :nrc
      t.string :product_type, default: 'good'
      t.integer :offer_id
      t.timestamps
    end
  end
end
