ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  #map.connect '', :controller => "quick/start" -- right now this is broken (11/4/08)
   map.connect '', :controller => "facilities", :action => 'list'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Shelter listings
  map.connect 'shelters/list/:state/counties/:parish', :controller => 'shelters', :action => 'list'
  map.connect 'shelters/list/:state/:region', :controller => 'shelters', :action => 'list'
  map.connect 'shelters/list/:state', :controller => 'shelters', :action => 'list'
  map.connect 'shelters/totals/:state/counties/:parish', :controller => 'shelters', :action => 'totals'
  map.connect 'shelters/totals/:state/:region', :controller => 'shelters', :action => 'totals'
  map.connect 'shelters/totals/:state', :controller => 'shelters', :action => 'totals'

  # Condition listings
  map.connect 'conditions/list/:state/counties/:parish', :controller => 'conditions', :action => 'list'
  map.connect 'conditions/list/:state/:region', :controller => 'conditions', :action => 'list'
  map.connect 'conditions/list/:state', :controller => 'conditions', :action => 'list'

  map.connect 'items/show/:id/:state/counties/:parish', :controller => 'items', :action => 'show'
  map.connect 'items/show/:id/:state/:region', :controller => 'items', :action => 'show'
  map.connect 'items/show/:id/:state', :controller => 'items', :action => 'show'

  map.connect 'categories/show/:id/:state/counties/:parish', :controller => 'categories', :action => 'show'
  map.connect 'categories/show/:id/:state/:region', :controller => 'categories', :action => 'show'
  map.connect 'categories/show/:id/:state', :controller => 'categories', :action => 'show'

  map.connect 'conditions/matches/:id/:avail/:state/counties/:parish', :controller => 'conditions', :action => 'matches'
  map.connect 'conditions/matches/:id/:avail/:state/:region', :controller => 'conditions', :action => 'matches'
  map.connect 'conditions/matches/:id/:avail/:state', :controller => 'conditions', :action => 'matches'
  map.connect 'conditions/matches/:id/:avail', :controller => 'conditions', :action => 'matches'
  # Install the default route as the lowest priority.
#  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
