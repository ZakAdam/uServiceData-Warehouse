Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'statics#home'
  get '/food', to: 'foods#index'
  get '/git', to: 'git_info#index'
  get '/services', to: 'ping#index'
  get '/upload', to: 'posts#index'
  post '/upload', to: 'posts#create'
  get '/get_file', to: 'posts#get_file'
end
