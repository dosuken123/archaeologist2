class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      # this line adds an integer column called `project_id`.
      t.references :user, index: true
      t.references :project, index: true
      t.text :task_name
      t.integer :task_status, :null => false, :default => 0
      t.text :memo
      t.integer :del_flg, :null => false, :default => 0

      t.timestamps null: false
    end
    add_foreign_key :tasks, :users
    add_foreign_key :tasks, :projects
  end
end
