class CreateInsecureUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :insecure_users do |t|
      t.string :name
      t.string :email
      t.boolean :admin

      t.timestamps
    end
  end
end
