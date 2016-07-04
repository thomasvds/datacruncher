Rails.application.routes.draw do

  get 'teams/index', as: 'teams'
  get 'tasks/index', as: 'tasks'
  get 'policies/index', as: 'policies'

  get 'reports/dashboard', as: 'dashboard'
  get 'reports/individual/:id', to: 'reports#individual', as: 'individual_report'
  get 'reports/team/:id', to: 'reports#team', as: 'team_report'
  get 'agents/:id', to: 'agents#show', as: 'agent'

  get 'orchestractor/slack'
  get 'orchestractor/github'

  root to: 'reports#dashboard'
end
