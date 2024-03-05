require 'rails_helper'
# ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.describe AddTransaction, type: :model do
  fixtures :all
  let(:client) { clients(:one) }
  context 'race condition' do
    it 'should not have a race condition' do
      expect(ActiveRecord::Base.connection.pool.size).to eq(5)
      wait_for_it = true
      threads = 4.times.map do |_|
        Thread.new do
          true while wait_for_it

          AddTransaction.new(client.id, 1000, 'c', 'test').call
        end
      end

      sleep 10
      wait_for_it = false
      threads.each(&:join)

      expect(client.reload.account_balance).to be(4000)
    end
  end
end
