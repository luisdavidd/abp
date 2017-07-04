class CreateLoanTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :loan_types do |t|
      t.string :type_name
      t.integer :amount
      t.integer :interest
      t.integer :fees

      t.timestamps
    end
  end
end
