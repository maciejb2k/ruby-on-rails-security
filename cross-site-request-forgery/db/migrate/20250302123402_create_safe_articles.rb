class CreateSafeArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :safe_articles do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
