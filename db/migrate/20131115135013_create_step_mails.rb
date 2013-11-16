class CreateStepMails < ActiveRecord::Migration
  def change
    create_table :step_mails do |t|
      t.integer :date
      t.text :subject
      t.text :header
      t.text :content
      t.text :footer

      t.timestamps
    end
  end
end
