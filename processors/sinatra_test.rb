# myapp.rb
require 'sinatra'

get '/' do
  'Hello world!'
end

get '/gls_invoice/process' do
  'this is gls invoice process for their processing ;)'
end
