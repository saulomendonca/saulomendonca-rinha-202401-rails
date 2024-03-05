class TransactionsController < ApplicationController
  def create
    case AddTransaction.new(*params.slice(:client_id, :valor, :tipo, :descricao).values).call
    in [:success, result]
      render json: result
    in [:failure, :client_not_found]
      head :not_found
    in [:failure, _]
      head :unprocessable_entity
    end
  end
end
