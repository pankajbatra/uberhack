class AddUserMobileAndAddress < ActiveRecord::Migration
  def change
    add_column :users, :mobile, :string
    add_column :users, :home, :string
    add_column :users, :office, :string
    add_column :users, :last_error_code, :string
  end
end
