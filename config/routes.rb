Rails.application.routes.draw do

  get 'orchestractor/slack', to: 'orchestractor#slack'
  get 'events', to: 'event#show'

end
