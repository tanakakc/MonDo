class ChangeReceiveMailTrueToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :receive_mail, true
  end
end
