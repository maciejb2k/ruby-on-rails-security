class Invoice < ApplicationRecord
  validates :name, :url, :issue_date, presence: true
end
