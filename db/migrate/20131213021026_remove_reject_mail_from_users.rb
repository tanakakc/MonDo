class RemoveRejectMailFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :reject_mail, :boolean
  end
end
