class AddTransaction
  attr_reader :client_id, :amount, :transaction_type, :description

  def initialize(client_id, amount, transaction_type, description)
    @client_id = client_id
    @amount = amount
    @transaction_type = transaction_type
    @description = description
  end

  def call
    client = Client.where(id: client_id).select(:id).take
    return %i[failure client_not_found] if client.nil?

    begin
      Client.transaction do
        transaction = client.transactions.create(amount:, transaction_type:, description:)
        return %i[failure invalid_transaction] if transaction.errors.present?

        result = update_client_balance
        [:success, result]
      end
    rescue StandardError
      %i[failure invalid_transaction]
    end
  end

  def update_client_balance
    update_query = transaction_type == 'c' ? update_client_balance_credit_sql : update_client_balance_debit_sql
    result = ActiveRecord::Base.connection.execute(update_query, { client_id:, amount: })

    raise RuntimeError if result.cmd_tuples.to_i != 1

    result.first
  end

  def update_client_balance_credit_sql
    <<-SQL.squish
      UPDATE clients
        SET account_balance = account_balance + #{amount}
      WHERE id = #{client_id}
      RETURNING account_limit AS limite, account_balance AS saldo
    SQL
  end

  def update_client_balance_debit_sql
    <<-SQL.squish
      UPDATE clients
        SET account_balance = account_balance - #{amount}
      WHERE id = #{client_id}
        AND (account_balance + account_limit >= #{amount})
      RETURNING account_limit AS limite, account_balance AS saldo
    SQL
  end
end
