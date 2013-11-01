class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.integer :user_id
      t.integer :date
      t.text :q1
      t.text :q2
      t.text :q3
      t.text :q4
      t.boolean :done

      t.timestamps
    end
  end
end
