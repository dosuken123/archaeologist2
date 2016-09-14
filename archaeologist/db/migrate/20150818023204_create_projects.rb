class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.text :project_name
      t.text :icon_path
      t.integer :del_flg, :null => false, :default => 0

      t.timestamps null: false
    end
  end
end
