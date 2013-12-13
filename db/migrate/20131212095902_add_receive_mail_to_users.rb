class AddReceiveMailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_mail, :boolean
  end
end
