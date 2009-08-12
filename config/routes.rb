ActionController::Routing::Routes.draw do |map|

  map.resources :locations
  map.connect 'locations/:action/:id', :controller => 'locations'

  map.search 'search', :controller => 'search', :action => 'search'
  map.stats 'stats', :controller => 'stats', :action => 'index'

  map.image 'file/image/:id', :controller => 'file', :action => 'image'
  map.audio_file 'file/audio/:id', :controller => 'file', :action => 'audio'

  map.root :controller => 'home', :action => 'index'
  map.login 'login', :controller => 'home', :action => 'login'
  map.logout 'logout', :controller => 'home', :action => 'logout'

#  map.connect ':controller/:action/:id'
end
