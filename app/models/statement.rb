class Statement
  attr_reader :client_id

  def initialize(client_id)
    @client_id = client_id
  end

  def call
    result = ActiveRecord::Base.connection.execute(statement_sql, { client_id: })
    result.first['statement']
  end

  def statement_sql
    <<-SQL.squish
    SELECT
      jsonb_build_object(
        'saldo', json_build_object(
          'total', account_balance ,
          'data_extrato', current_timestamp,
          'limite', account_limit
        ),
        'ultimas_transacoes', jsonb_agg_strict(transactions)
      )
    AS statement
    FROM public.clients
    LEFT JOIN (
      SELECT
        amount AS "valor",
        transaction_type AS  "tipo",
        description AS "descricao",
        transaction_date AS  "realizada_em"
      FROM public.transactions
      WHERE client_id = #{client_id}
      ORDER BY id DESC
      LIMIT 10
    ) transactions ON true
    WHERE id = #{client_id}
    GROUP BY clients.account_balance, clients.account_limit
    SQL
  end
end
