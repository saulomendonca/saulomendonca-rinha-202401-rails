class BankStatementsController < ApplicationController
  def show
    if Client.where(id: params[:client_id]).exists?
      result = Statement.new(params[:client_id]).call
      render json: result
    else
      head :not_found
    end
  end
end
