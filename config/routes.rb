Rails.application.routes.draw do
  get 'pages/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "main#index"

  # delete everything
  # post 'delete', to: 'delete#collections'

  post 'send', to: 'send#message'

  get 'receive', to: 'receive#message'

  get 'ecdsa', to: 'ecdsa#keys'

  get 'rsa', to: 'rsa#keys'

end
