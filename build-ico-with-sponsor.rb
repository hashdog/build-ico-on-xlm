require "stellar-sdk"
require "stellar-base"

include Stellar::DSL


### Network
horizon_client     = Stellar::Client.default_testnet
network_passphrase = Stellar::Networks::TESTNET

### Accounts
sponsoring = Stellar::KeyPair.random
horizon_client.friendbot(sponsoring)

new_account = KeyPair()

### Config ICO
ico_name          = "BOX"
asset             = Asset("#{ico_name}-#{sponsoring.address}")
lumens            = Asset("XLM-native")
max_supply        = 1000000
starting_balance  = 500
initial_price     = 1

seq_num = horizon_client.account_info(sponsoring.address).sequence.to_i

tb = Stellar::TransactionBuilder.new(
  source_account: sponsoring,
  network_passphrase: network_passphrase,
  sequence_number: seq_num + 1,
).add_operation(
    Stellar::Operation.begin_sponsoring_future_reserves(
      sponsored: new_account
    )
).add_operation(
    Stellar::Operation.create_account(
      destination: new_account,
      starting_balance: 0
    )
).add_operation(
    Stellar::Operation.change_trust(
      source_account: new_account,
      line: asset,
      limit: 10000
    )
).add_operation(
  Stellar::Operation.payment(
    source_account: sponsoring,
    destination: new_account,
    amount: [asset, 1000]
  )
).add_operation(
  Stellar::Operation.manage_sell_offer(
    source_account: new_account,
    selling: asset,
    buying: lumens,
    amount: 100,
    price: 0.1
  )
).add_operation(
    Stellar::Operation.end_sponsoring_future_reserves(
      source_account: new_account
    )
)

tx = tb.build
envelope = tx.to_envelope(sponsoring, new_account)

response = horizon_client.submit_transaction(tx_envelope: envelope)
p "Transaction was submitted successfully. It's hash is #{response.id}"
# OutTheBox
p "=== Sponsoring Account"
p "Address: #{sponsoring.address}"
p "Seed: #{sponsoring.seed}\n\n"

p "=== Distributor Account"
p "Address: #{new_account.address}"
p "Seed: #{new_account.seed}\n\n"