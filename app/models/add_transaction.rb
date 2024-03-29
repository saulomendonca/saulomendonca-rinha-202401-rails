class AddTransaction
  attr_reader :client_id, :amount, :transaction_type, :description

  def initialize(client_id, amount, transaction_type, description)
    @client_id = client_id
    @amount = amount
    @transaction_type = transaction_type
    @description = description
  end

  def call
    return %i[failure invalid_transaction] unless valid?

    client = Client.find_by(id: client_id)
    return %i[failure client_not_found] if client.nil?

    has_limit = transaction_type == 'd' && amount > client.account_balance + client.account_limit
    return %i[failure invalid_transaction] if has_limit

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

  def valid?
    return unless @amount.kind_of?(Integer) && @amount > 0
    return unless %w[c d].include? @transaction_type
    return if @description.nil? || !@description.size.between?(1,10)

    true
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
