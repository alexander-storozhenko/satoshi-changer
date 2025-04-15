# frozen_string_literal: true

def get_exchange_rate(symbol)
  HTTParty.get("https://api.binance.com/api/v3/ticker/price?symbol=#{symbol}").parsed_response
end
