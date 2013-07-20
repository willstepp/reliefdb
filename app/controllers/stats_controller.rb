class StatsController < ApplicationController

  layout "general"

  def list
  end

  def by_user
     @yesterday = historical_count("1 day")
     @lastweek = historical_count("1 week")
     @lastyear = historical_count("1 year")
   end

  def access_shelters 
    @user = User.find(params[:id])
  end
  
  def add_shelter    
    @user = User.find(params[:user_id])
    @shelter = Shelter.find(params[:shelter][:id])
    @user.shelters << @shelter
    @user.save
    render :action => "access_shelters"
  end
  
  def historical_count(interval)
    History.find_by_sql(["select login,firstname || ' ' || lastname as name,recap.* from (
      select updated_by_id,
        sum(case when was_new = true and objtype = 'Category' then 1 else 0 end) as category_new,
        sum(case when (was_new = false or was_new IS NULL) and objtype = 'Category' then 1 else 0 end) as category_update,
        sum(case when was_new = true and (objtype = 'Need' or objtype = 'Surplus') then 1 else 0 end) as condition_new,
        sum(case when (was_new = false or was_new IS NULL) and (objtype = 'Need' or objtype = 'Surplus') then 1 else 0 end) as condition_update,
        sum(case when was_new = true and objtype = 'Item'then 1 else 0 end) as item
      from histories
      where timestamp >= current_date - interval ?
      group by updated_by_id ) as recap
      join users
        on users.id = recap.updated_by_id
      order by login",interval])
  end
end
