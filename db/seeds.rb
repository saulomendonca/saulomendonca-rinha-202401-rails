# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#

[
    { name:'o barato sai caro', account_limit: 1_000_00 },
    { name:'zan corp ltda', account_limit: 800_00 },
    { name:'les cruders', account_limit: 10_000_00 },
    { name:'padaria joia de cocaia', account_limit: 100_000_00 },
    { name:'kid mais', account_limit: 5_000_00 }
].each do |client|
  Client.create!(client)
end
