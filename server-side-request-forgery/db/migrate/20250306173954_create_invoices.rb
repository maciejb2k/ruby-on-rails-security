class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.string :url
      t.text :raw_data
      t.text :parsed_data
      t.string :status
      t.string :name
      t.date :issue_date

      t.timestamps
    end
  end
end
