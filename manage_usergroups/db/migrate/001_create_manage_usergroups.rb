class CreateManageUsergroups < ActiveRecord::Migration
  def change
    create_table :manage_usergroups do |t|
      t.integer :group_id
      t.integer :manager_id
    end
  end
end
