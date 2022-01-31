Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'transport_invoices/save', to: 'transport_invoices#new_invoice'
  post 'package_tracking/save', to: 'package_trackings#new_tracking'
  post 'reviews/save'

  post 'heureka_reviews/save', to: 'heureka_reviews#new_review'
end
