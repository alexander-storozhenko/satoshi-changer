require 'sinatra'
require 'json'

require_relative '../../helpers/transaction_helper'
require_relative '../../helpers/address_helper'

module API
  module Transaction
    class Create < Sinatra::Base
      include API::Cors

      SUPPORTED_ADDR_TYPES = %i[P2PKH P2SH]
      SEND_LIMIT = 30

      before do
        content_type :json
      end

      post '/transaction/create' do
        body = JSON.parse(request.body.read)
        recipient_address = body['recipient_address']
        amount = body['amount']
        symbol = body['symbol']

        unless recipient_address
          status 400
          break { err: "recipient_address required" }
        end

        if amount > SEND_LIMIT
          status 400
          break { err: "send limit #{SEND_LIMIT} USDT" }
        end

        if amount < 1
          status 400
          break { err: "dust" }
        end

        unless SUPPORTED_ADDR_TYPES.include?(address_type(recipient_address))
          status 400
          break { err: "#{recipient_address} addr type is unsupported" }
        end

        p symbol
        response = get_exchange_rate(symbol)
        p response
        symbol_amount = amount.to_f / response['price'].to_f

        p recipient_address

        tx = create_signet_tx(recipient_address, symbol_amount)

        status 201
        tx.to_json
      end
    end
  end
end

