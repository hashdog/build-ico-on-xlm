require 'rubygems'
require 'bundler/setup'

require "stellar-sdk"
require "stellar-base"
include Stellar::DSL


### Network
horizon_client     = Stellar::Client.default_testnet

### Accounts
issuer = Stellar::KeyPair.random
horizon_client.friendbot(issuer)

distributor = Stellar::KeyPair.random
horizon_client.friendbot(distributor)

### Config ICO
ico_name      = "BOX"
asset         = Asset("#{ico_name}-#{issuer.address}")
lumens        = Asset("XLM-native")
max_supply    = 1000000
initial_price = 1

#Build TXS
seq_num = horizon_client.account_info(issuer.address).sequence.to_i

tb = Stellar::TransactionBuilder.new(
  source_account: issuer,
  sequence_number: seq_num + 1
).add_operation(
    Stellar::Operation.change_trust(
      source_account: distributor,
      line: asset,
      limit: max_supply
    )
).add_operation(
  Stellar::Operation.payment(
    source_account: issuer,
    destination: distributor,
    amount: [asset, max_supply]
  )
).add_operation(
  Stellar::Operation.set_options({
      source_account: issuer,
      master_weight: 0,
      low_threshold: 1,
      med_threshold: 1,
      high_threshold: 1
})).add_operation(
  Stellar::Operation.manage_sell_offer(
    source_account: distributor,
    selling: asset,
    buying: lumens,
    amount: max_supply,
    price: initial_price
  )
)

#Send TXS
tx        = tb.build
envelope  = tx.to_envelope(issuer, distributor)
response  = horizon_client.submit_transaction(tx_envelope: envelope)
p "Transaction was submitted successfully. It's hash is #{response.id}\n\n"

# OutTheBox
p "=== Issuer Account"
p "Address: #{issuer.address}"
p "Seed: #{issuer.seed}\n\n"

p "=== Distributor Account"
p "Address: #{distributor.address}"
p "Seed: #{distributor.seed}\n\n"