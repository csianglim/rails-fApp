class Account < ApplicationRecord
  has_paper_trail
  validates :name, presence: true
  validates :amount, presence: true, numericality: true, :format => { :with => /\A\d+\.*\d{0,2}\z/ }
end
