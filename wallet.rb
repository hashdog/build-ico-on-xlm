require "stellar-sdk"
require "./horizon-wrapper/horizon_wrapper"

r = HorizonWrapper::HTTP.get("/accounts/GDFIY5IA6GSX7TIUZU3ZUEJWJLXSA333N6DRLBJPZHNO2AJKZF2XTPSQ")

puts r.inspect

