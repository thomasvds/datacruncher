Rails.application.routes.draw do

  get 'orchestractor/slack', to: 'orchestractor#slack'
  get 'orchestractor/github', to: 'orchestractor#github'
  get 'agents/:id', to: 'agents#show', as: 'agent'
  get 'policies/index', to: 'policies#index', as: 'policies'
  get 'reports/individual/:id', to: 'reports#individual', as: 'individual_report'
  get 'reports/dashboard', to: 'reports#dashboard', as: 'dashboard'

  root to: 'policies#index'
end
