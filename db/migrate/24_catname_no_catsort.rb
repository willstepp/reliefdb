class CatnameNoCatsort < ActiveRecord::Migration
  def self.up

    execute "CREATE FUNCTION catname(varchar)
               RETURNS varchar
               AS 'SELECT CASE WHEN char_length($1) = 0 OR $1 IS NULL THEN chr(255) ELSE upper($1) END;'
               LANGUAGE SQL IMMUTABLE;"

  end

  def self.down
  end
end
