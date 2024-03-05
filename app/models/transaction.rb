class Transaction < ApplicationRecord
  belongs_to :client

  enum :transaction_type, { credito: 'c', debito: 'd' }, validate: true

  validates :amount, numericality: { only_integer: true, greater_than: 0 }
  validates :description, length: { in: 1..10 }
end
