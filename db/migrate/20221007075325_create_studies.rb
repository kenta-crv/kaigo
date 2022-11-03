class CreateStudies < ActiveRecord::Migration[5.1]
  def change
    create_table :studies do |t|
      t.string :question
      t.string :genre
      t.string :kategory
      t.string :year
      t.string :answer
      t.references :worker, foreign_key: true
      t.timestamps
    end
  end
end
