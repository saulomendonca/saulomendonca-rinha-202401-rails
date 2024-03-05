require 'rails_helper'
# ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.describe 'Transactions', type: :request do
  fixtures :clients

  describe 'GET /create' do
    let(:client) { clients(:one) }
    let(:valor) { 1000 }
    let(:tipo) { 'c' }
    let(:descricao) { 'descricao' }

    context 'valid data' do
      it 'returns http success' do
        post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: }
        expect(response).to have_http_status(:success)
      end

      it 'returns a hash with limit and saldo' do
        post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: }
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:limite]).to eq(1_000_00)
        expect(json[:saldo]).to eq(1000)
      end

      it 'should create a transaction' do
        expect {
          post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } 
        }.to change { Transaction.count }.by(1)

        transaction = Transaction.last
        expect(transaction.transaction_type).to eq('credito')
        expect(transaction.client_id).to eq(client.id)
        expect(transaction.amount).to eq(1000)
        expect(transaction.description).to eq('descricao')
      end

      context 'debit' do
        let(:valor) { 100000 }
        let(:tipo) { 'd' }

        it 'returns http success' do
          post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } 
          expect(response).to have_http_status(:success)
        end

        it 'returns a hash with limit and saldo' do
          post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } 
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body).deep_symbolize_keys
          expect(json[:limite]).to eq(1_000_00)
          expect(json[:saldo]).to eq(-1_000_00)
        end

        it 'should create a transaction' do
          expect {
            post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } 
          }.to change { Transaction.count }.by(1)

          transaction = Transaction.last
          expect(transaction.transaction_type).to eq('debito')
          expect(transaction.client_id).to eq(client.id)
          expect(transaction.amount).to eq(100000)
          expect(transaction.description).to eq('descricao')
        end
      end
    end

    context 'invalid balance' do
      let(:valor) { 100100 }
      let(:tipo) { 'd' }

      it 'returns http unprocessable_entity' do
        post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should not create a transaction' do
        expect {
          post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } 
        }.to change { Transaction.count }.by(0)
      end
    end

    context 'invalid client' do
      it 'returns http not_found' do
        post '/clientes/0/transacoes', params: { valor:, tipo:, descricao: }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'invalid params' do
      before { post "/clientes/#{client.id}/transacoes", params: { valor:, tipo:, descricao: } }

      context 'invalid valor' do
        let(:valor) { 'rrr' }
        it 'returns http not_found' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'invalid tipo' do
        let(:tipo) { 'f' }
        it 'returns http not_found' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'empty description' do
        let(:descricao) { '' }
        it 'returns http not_found' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'description too big' do
        let(:descricao) { 'a' * 11 }
        it 'returns http not_found' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
