Rails.application.routes.draw do

  get 'orchestractor/slack', to: 'orchestractor#slack'
  get 'orchestractor/github', to: 'orchestractor#github'
  get 'events', to: 'event#index'
  get 'agents/:id', to: 'agent#show', as: 'agent'
  get 'policies/index', to: 'policy#index', as: 'policies'

  root to: 'policy#index'
end
