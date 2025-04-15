require './server'
require_relative 'api/cors'
require_relative 'api/transaction/create'
require_relative 'api/exchange_rate/get'

use API::Transaction::Create
use API::ExchangeRate::Get

run Sinatra::Application