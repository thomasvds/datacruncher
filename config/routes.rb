Rails.application.routes.draw do

  get 'orchestractor/slack', to: 'orchestractor#slack'
  get 'orchestractor/github', to: 'orchestractor#github'
  get 'events', to: 'event#index'
  get 'agents/:id', to: 'agent#show'

end
