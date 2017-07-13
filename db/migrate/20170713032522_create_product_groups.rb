class CreateProductGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :product_groups do |t|
      t.string :group_name
      t.integer :nrc
      t.integer :exam_total
      t.integer :lab_total

      t.timestamps
    end
  end
end
