class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.string :statu
      t.datetime :time
      t.string :comment
      t.references :customer, foreign_key: true
      t.references :admin, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
