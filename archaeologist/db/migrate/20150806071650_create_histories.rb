class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :user, index: true
      t.references :project, index: true
      t.references :task, index: true
      t.integer :is_off, :null => false, :default => 0
      t.integer :del_flg, :null => false, :default => 0

      t.timestamps null: false
    end
    add_foreign_key :histories, :users
    add_foreign_key :histories, :projects
    add_foreign_key :histories, :tasks
  end
end
