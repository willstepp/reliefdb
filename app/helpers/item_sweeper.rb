class ItemSweeper < ActionController::Caching::Sweeper
  observe Item

  def after_save(record)
    clear_cache(record)
  end  
  
  def after_destroy(record)
    clear_cache(record)
  end  

  def clear_cache(record)
    if record.is_a?(Item)
      expire_fragment(:controller => 'items', :action => 'list', :action_suffix => 'alphabetical')
      expire_fragment(:controller => 'items', :action => 'list', :action_suffix => 'bycategory')
    end
  end

end

