class CreateSubjectNrcs < ActiveRecord::Migration[5.0]
  def change
    create_table :subject_nrcs do |t|
      t.references :subject, foreign_key: true
      t.integer :nrc

      t.timestamps
    end
  end
end
