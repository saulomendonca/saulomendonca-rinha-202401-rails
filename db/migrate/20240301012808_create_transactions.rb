class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.integer :amount
      t.string :transaction_type
      t.string :description
      t.datetime :transaction_date, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.references :client, null: false, foreign_key: true
    end
  end
end
