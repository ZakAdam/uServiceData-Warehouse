Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  puts "moreeeeeeeeeeeeeeeeeeeeeee"
  post '/new_invoice', to: 'invoices#new'
end
