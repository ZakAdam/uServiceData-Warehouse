Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'transport_invoices/save', to: 'transport_invoices#new_invoice'
  post 'package_tracking/save', to: 'package_trackings#new_tracking'
  post 'heureka_reviews/save', to: 'heureka_reviews#new_review'
  post 'review/save', to: 'review#new_review'
  post 'package_simple/save', to: 'package_simple#new_package'

  post 'package_simple/new_depot', to: 'package_simple#create_depot'
  get 'package_simple/depots', to: 'package_simple#get_depots'
  get 'package_simple/last_id', to: 'package_simple#get_last_id'
end
