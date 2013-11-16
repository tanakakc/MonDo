class AddMailDoneToDays < ActiveRecord::Migration
  def change
    add_column :days, :mail_done, :boolean
  end
end
