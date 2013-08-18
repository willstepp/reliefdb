Reliefdb::Application.routes.draw do
  root :to => 'facilities#list'

  match 'shelters/list/:state/counties/:parish', :to => 'shelters#list'
  match 'shelters/list/:state/:region', :to => 'shelters#list'
  match 'shelters/list/:state', :to => 'shelters#list'
  match 'shelters/totals/:state/counties/:parish', :to => 'shelters#totals'
  match 'shelters/totals/:state/:region', :to => 'shelters#totals'
  match 'shelters/totals/:state', :to => 'shelters#totals'

  match 'conditions/list/:state/counties/:parish', :to => 'conditions#list'
  match 'conditions/list/:state/:region', :to => 'conditions#list'
  match 'conditions/list/:state', :to => 'conditions#list'

  match 'items/show/:id/:state/counties/:parish', :to => 'items#show'
  match 'items/show/:id/:state/:region', :to => 'items#show'
  match 'items/show/:id/:state', :to => 'items#show'

  match 'categories/show/:id/:state/counties/:parish', :to => 'categories#show'
  match 'categories/show/:id/:state/:region', :to => 'categories#show'
  match 'categories/show/:id/:state', :to => 'categories#show'

  match 'conditions/matches/:id/:avail/:state/counties/:parish', :to => 'conditions#matches'
  match 'conditions/matches/:id/:avail/:state/:region', :to => 'conditions#matches'
  match 'conditions/matches/:id/:avail/:state', :to => 'conditions#matches'
  match 'conditions/matches/:id/:avail', :to => 'conditions#matches'

  match ':controller(/:action(/:id))(.:format)'
end
