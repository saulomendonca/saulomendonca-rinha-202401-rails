class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :account_limit
      t.integer :account_balance, default: 0
    end
  end
end
