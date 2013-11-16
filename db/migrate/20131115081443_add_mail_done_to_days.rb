class AddMailDoneToDays < ActiveRecord::Migration
  def change
    add_column :days, :mail_done, :boolen
  end
end
