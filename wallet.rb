require "stellar-sdk"
require_relative "horizon-wrapper/http"

r = HorizonWrapper::HTTP.get("/accounts/GDFIY5IA6GSX7TIUZU3ZUEJWJLXSA333N6DRLBJPZHNO2AJKZF2XTPSQ")

puts r.inspect

