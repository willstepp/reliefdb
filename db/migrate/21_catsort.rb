class Catsort < ActiveRecord::Migration
  def self.up
    execute "CREATE FUNCTION catsort(varchar, varchar)
               RETURNS boolean
               AS 'SELECT CASE WHEN char_length($2) = 0 AND char_length($1) > 0 THEN true WHEN char_length($1) = 0 THEN false WHEN upper($1) < upper($2) THEN true ELSE false END;'
               LANGUAGE SQL IMMUTABLE;"
    execute "CREATE OPERATOR < (PROCEDURE = catsort, LEFTARG = varchar, RIGHTARG = varchar);"
  end

  def self.down
    execute "DROP OPERATOR < (varchar, varchar);"
    execute "DROP FUNCTION catsort(varchar, varchar);"
  end
end
