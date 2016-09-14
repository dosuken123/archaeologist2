class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :user_name, :null => false, :unique => true
      t.text :icon_path
      t.text :background_image_path
      t.integer :del_flg, :null => false, :default => 0

      t.timestamps null: false
    end
  end
end
