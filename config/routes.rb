Reliefdb::Application.routes.draw do
  root :to => 'facilities#list', via: [:get, :post]

  match 'shelters/list/:state/counties/:parish', :to => 'shelters#list', via: [:get, :post]
  match 'shelters/list/:state/:region', :to => 'shelters#list', via: [:get, :post]
  match 'shelters/list/:state', :to => 'shelters#list', via: [:get, :post]
  match 'shelters/totals/:state/counties/:parish', :to => 'shelters#totals', via: [:get, :post]
  match 'shelters/totals/:state/:region', :to => 'shelters#totals', via: [:get, :post]
  match 'shelters/totals/:state', :to => 'shelters#totals', via: [:get, :post]

  match 'conditions/list/:state/counties/:parish', :to => 'conditions#list', via: [:get, :post]
  match 'conditions/list/:state/:region', :to => 'conditions#list', via: [:get, :post]
  match 'conditions/list/:state', :to => 'conditions#list', via: [:get, :post]

  match 'items/show/:id/:state/counties/:parish', :to => 'items#show', via: [:get, :post]
  match 'items/show/:id/:state/:region', :to => 'items#show', via: [:get, :post]
  match 'items/show/:id/:state', :to => 'items#show', via: [:get, :post]

  match 'categories/show/:id/:state/counties/:parish', :to => 'categories#show', via: [:get, :post]
  match 'categories/show/:id/:state/:region', :to => 'categories#show', via: [:get, :post]
  match 'categories/show/:id/:state', :to => 'categories#show', via: [:get, :post]

  match 'conditions/matches/:id/:avail/:state/counties/:parish', :to => 'conditions#matches', via: [:get, :post]
  match 'conditions/matches/:id/:avail/:state/:region', :to => 'conditions#matches', via: [:get, :post]
  match 'conditions/matches/:id/:avail/:state', :to => 'conditions#matches', via: [:get, :post]
  match 'conditions/matches/:id/:avail', :to => 'conditions#matches', via: [:get, :post]

  match ':controller(/:action(/:id))(.:format)', via: [:get, :post]
end
