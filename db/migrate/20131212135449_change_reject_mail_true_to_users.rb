class ChangeRejectMailTrueToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :reject_mail, false
  end
end
