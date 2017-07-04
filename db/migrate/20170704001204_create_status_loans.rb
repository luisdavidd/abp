class CreateStatusLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :status_loans do |t|
      t.integer :student_id
      t.integer :nrc
      t.integer :loan_stat
      t.integer :type_id
      t.integer :amount
      t.integer :next_payment
      t.integer :current_fee
      t.datetime :starting_in

      t.timestamps
    end
  end
end
