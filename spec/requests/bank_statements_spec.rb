require 'rails_helper'

RSpec.describe "BankStatements", type: :request do
  fixtures :clients

  describe "GET /show" do
    context 'client exists' do
      let(:client) { clients(:two) }

      before { get "/clientes/#{client.id}/extrato" }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a 'saldo' response" do
        statement = JSON.parse(response.body).deep_symbolize_keys
        expect(statement[:saldo]).to_not be_empty
        expect(statement[:saldo][:total]).to eq(3_000_00)
        expect(statement[:saldo][:data_extrato]).to_not be_empty
        expect(statement[:saldo][:limite]).to eq(2_000_00)
      end

      it "returns a 'ultimas_transacoes' response" do
        statement = JSON.parse(response.body).deep_symbolize_keys
        expect(statement[:ultimas_transacoes].length).to eq(10)
        first_trasaction = statement[:ultimas_transacoes].first
        expect(first_trasaction[:valor]).to eq(400_00)
        expect(first_trasaction[:tipo]).to eq('c')
        expect(first_trasaction[:descricao]).to eq('AAA11')
        expect(first_trasaction[:realizada_em]).to eq('2021-12-11T10:00:00')

        last_trasaction = statement[:ultimas_transacoes].last
        expect(last_trasaction[:valor]).to eq(100_00)
        expect(last_trasaction[:tipo]).to eq('d')
        expect(last_trasaction[:descricao]).to eq('AAA2')
        expect(last_trasaction[:realizada_em]).to eq('2022-01-02T10:00:00')
      end
    end

    context 'client does not exist' do
      it "returns http 404" do
        get "/clientes/20/extrato"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
