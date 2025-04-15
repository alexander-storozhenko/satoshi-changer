require_relative '../../helpers/binance_helper'
require 'sinatra'
require 'json'

module API
  module ExchangeRate
    class Get < Sinatra::Base
      include API::Cors

      before do
        content_type :json
      end

      get '/exchange_rate' do
        symbol = params['symbol']

        p symbol

        response = get_exchange_rate(symbol)

        if response['code'] && response['code'] < 0
          status 400
          break response.to_json
        end

        status 200
        response.to_json
      end
    end
  end
end

