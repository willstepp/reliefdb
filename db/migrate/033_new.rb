class New < ActiveRecord::Migration
  def self.up
    execute "CREATE OR REPLACE FUNCTION is_this_user(shelter_id integer, user_id integer)
      RETURNS boolean AS
      $BODY$select $2 = any(array(select user_id from shelters_users
      where shelter_id = $1))$BODY$
      LANGUAGE 'sql' VOLATILE;
    ALTER FUNCTION is_this_user(shelter_id integer, user_id integer) OWNER TO postgres;"    
  end

  def self.down
    execute "DROP FUNCTION is_this_user(shelter_id integer, user_id integer);"    
  end
end
