require "stellar-sdk"
require "stellar-base"
include Stellar::DSL

# TESTNET
client      = Stellar::Client.default_testnet
custom_coin = "BORX"
max_supply  = 1000000

#STEP 1: CREATE ISSUER
issuer = Stellar::KeyPair.random
client.friendbot(issuer)
puts "Creating issuer account..."
puts "PUBLIC: #{issuer.address}"
puts "SECRET: #{issuer.seed}"
puts "https://stellar.expert/explorer/testnet/search?term=#{issuer.address}\n\n"


#STEP 2: CREATE DISTRIBUTOR
distributor = Stellar::KeyPair.random
client.friendbot(distributor)
puts "Creating distributor account..."
puts "PUBLIC: #{distributor.address}"
puts "SECRET: #{distributor.seed}"
puts "https://stellar.expert/explorer/testnet/search?term=#{distributor.address}\n\n"

#STEP 3: ALLOW TRUST BETWEEN distributor AND ISSUER
puts "Allow trust bettewen distributor and issuer"

seq_num = client.account_info(distributor.address).sequence.to_i

builder = Stellar::TransactionBuilder.new(
  source_account: distributor,
  sequence_number: seq_num + 1
)

change_trust_op = Stellar::Operation.change_trust({
  line: Stellar::Asset.alphanum4(custom_coin, issuer),
  limit: max_supply # this is optional
})

tx = builder.add_operation(change_trust_op).set_timeout(600).build

envelope = tx.to_envelope(distributor).to_xdr(:base64)

client.horizon.transactions._post(tx: envelope)

#STEP 5: CREATE NEW ICO
puts "Creating #{custom_coin} ICO"
# puts "Retrieving account's current sequence number..."
seq_num = client.account_info(issuer.address).sequence.to_i

builder = Stellar::TransactionBuilder.new(
  source_account: issuer,
  sequence_number: seq_num + 1
)
# Note: if you want to send a non-native asset, :amount must take the form:
# [<:alphanum12 or :alphanum4>, <code>, <issuer keypair>, <amount>]
payment_op = Stellar::Operation.payment({
  destination: distributor,
  amount: [:alphanum4, custom_coin, issuer, max_supply]
})

# # add payment to transaction and set a 600ms timeout
tx = builder.add_operation(payment_op).set_timeout(600).build
# # sign transaction and get xdr
envelope = tx.to_envelope(issuer).to_xdr(:base64)
client.horizon.transactions._post(tx: envelope)

#STEP 6: LOCK ISSUER
puts "Look Issuer account"

# puts "Retrieving account's current sequence number..."
seq_num = client.account_info(issuer.address).sequence.to_i

builder = Stellar::TransactionBuilder.new(
  source_account: issuer,
  sequence_number: seq_num + 1
)
# Note: if you want to send a non-native asset, :amount must take the form:
# [<:alphanum12 or :alphanum4>, <code>, <issuer keypair>, <amount>]
operation = Stellar::Operation.set_options({
      master_weight: 0,
      low_threshold: 1,
      med_threshold: 1,
      high_threshold: 1
})

tx = builder.add_operation(operation).set_timeout(600).build
envelope = tx.to_envelope(issuer).to_xdr(:base64)
client.horizon.transactions._post(tx: envelope)


#MAKE SELL OFFER
#op = Stellar::Operation.manage_buy_offer(buying: buying_asset, selling: selling_asset, buyAmount: 50, price: 10)
#Stellar::Asset.alphanum4
asset  = Asset("#{custom_coin}-#{issuer.address}")
lumens = Asset("XLM-native")

seq_num = client.account_info(distributor.address).sequence.to_i

builder = Stellar::TransactionBuilder.new(
  source_account: distributor,
  sequence_number: seq_num + 1
)

operation =  Stellar::Operation.manage_sell_offer(
    selling: asset,
    buying: lumens,
    amount: max_supply,
    price: 1
  )

tx = builder.add_operation(operation).set_timeout(600).build
envelope = tx.to_envelope(distributor).to_xdr(:base64)
client.horizon.transactions._post(tx: envelope)

puts "\n\nICO #{custom_coin} is Success!\n\n"

puts "Name: #{custom_coin}"
puts "Total Supply: #{max_supply}"
puts "Check ICO on https://stellar.expert/explorer/testnet/search?term=#{issuer.address}"
