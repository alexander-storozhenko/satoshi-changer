# frozen_string_literal: true
require 'sinatra'
require 'sinatra/cors'

configure do
  set :server, :puma
end

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:3000',
          'Access-Control-Allow-Credentials' => 'true',
          'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept, Authorization'
end

options '*' do
  204 # No Content
end