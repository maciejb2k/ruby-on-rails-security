class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :param1
      t.text :param2

      t.timestamps
    end
  end
end
