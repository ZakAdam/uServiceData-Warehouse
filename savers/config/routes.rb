Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'transport_invoices/save', to: 'transport_invoices#new_invoice'
  post 'package_tracking/save'
  post 'reviews/save'
end
