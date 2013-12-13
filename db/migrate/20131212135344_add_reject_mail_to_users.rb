class AddRejectMailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reject_mail, :boolean
  end
end
