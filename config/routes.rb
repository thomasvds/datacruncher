Rails.application.routes.draw do

  get 'pages/employee_info'

  get 'pages/employer_info'

  get 'pages/about'

  get 'teams/index', as: 'teams'
  get 'tasks/index', as: 'tasks'
  get 'policies/index', as: 'policies'

  get 'reports/company', as: 'company'
  get 'reports/individual/:id', to: 'reports#individual', as: 'individual_report'
  get 'reports/team/:id', to: 'reports#team', as: 'team_report'
  get 'agents/:id', to: 'agents#show', as: 'agent'

  get 'orchestractor/slack'
  get 'orchestractor/github'

  get 'reports/data'
  get 'reports/testjson'

  root to: 'reports#company'
end
