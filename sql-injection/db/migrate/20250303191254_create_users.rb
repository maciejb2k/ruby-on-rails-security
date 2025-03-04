class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.integer :age
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
