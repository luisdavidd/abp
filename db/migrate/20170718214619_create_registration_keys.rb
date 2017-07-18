class CreateRegistrationKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :registration_keys do |t|
      t.string :validations

      t.timestamps
    end
  end
end
