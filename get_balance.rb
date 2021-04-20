require 'rubygems'
require 'bundler/setup'
require "stellar-sdk"
require_relative "horizon-wrapper/http"

### Account
client = Stellar::Client.default_testnet
account = Stellar::KeyPair.random

### Get balance using rest api
client.friendbot(account)
res = HorizonWrapper::HTTP.get("/accounts/#{account.address}")
#check balances with horizon
puts "### Get Balance using horizon rest-api"
res.payload["balances"].each do |balance|
  asset_code = balance["asset_type"] == "native" ? "XLM" : balance["asset_code"]
  puts "#{asset_code}: #{balance["balance"]}"
end


### Get balance using sdk
puts "### Get Balance using stella sdk"
info = client.account_info(account.address)
info["balances"].each do |balance|
  asset_code = balance["asset_type"] == "native" ? "XLM" : balance["asset_code"]
  puts "#{asset_code}: #{balance["balance"]}"
end
