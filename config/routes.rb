Rails.application.routes.draw do
  get 'pages/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "main#index"

  # delete everything
  # post 'delete', to: 'delete#collections'

  # posting a message
  post 'send', to: 'send#message'

  # recieving a single message
  get 'receive', to: 'receive#message'

  # get a list of messages from a user
  get 'search', to: 'search#messages'

  # like search but also reads them
  get 'read', to: 'read#messages'

  #add user
  post 'add', to: 'add#user'

  # generate new user with key pair
  post 'generate', to: 'generate#user'

  # generate a keypair
  get 'ecdsa', to: 'ecdsa#keys'

  get 'rsa', to: 'rsa#keys'



end
