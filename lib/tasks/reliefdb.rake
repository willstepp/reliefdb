namespace :reliefdb do

  desc "Imports data from legacy database to new one"
  task import_data: :environment do
    #connect to cat_production database
    #adapter: postgresql
    #database: cat_production
    #username: citizen
    #password: Citizen
    #host: localhost

    cat_conn = PG.connect(host: 'localhost', 
                          port: 5432,
                          options: nil,
                          tty: nil,
                          dbname: 'cat_production',
                          user: 'citizen',
                          password: 'Citizen')

    rdb_conn = PG.connect(host: 'localhost', 
                          port: 5432,
                          options: nil,
                          tty: nil,
                          dbname: 'reliefdb_development',
                          user: 'postgres',
                          password: 'thisisapasswordmotherfucker')
    
    begin

      #categories
=begin
      res = cat_conn.exec('select * from categories')
      res.each do |r|
        puts r['id']
        puts r['created_at']
        puts r['updated_at']
        puts r['name']
        puts r['notes']
        rdb_conn.exec_params('INSERT INTO categories(id, description, created_at, updated_at, name) VALUES ($1, $2, $3, $4, $5);', [r['id'], r['notes'], r['created_at'], r['updated_at'], r['name']])
      end
=end
      #items
=begin
      res = cat_conn.exec('select * from items')
      res.each do |r|
        puts r['id']
        puts r['created_at']
        puts r['updated_at']
        puts r['name']
        puts r['notes']
        puts r['qty_per_pallet']
        rdb_conn.exec_params('INSERT INTO items(id, description, created_at, updated_at, name, quantity) VALUES ($1, $2, $3, $4, $5, $6);', [r['id'], r['notes'] ? r['notes'].force_encoding('iso8859-1').encode('utf-8') : nil, r['created_at'], r['updated_at'], r['name'] ? r['name'].force_encoding('iso8859-1').encode('utf-8') : nil, r['qty_per_pallet']])
      end
=end
      #categories_items
      res = cat_conn.exec('select * from categories_items')
      res.each do |r|
        puts r['category_id']
        puts r['item_id']
        rdb_conn.exec_params('INSERT INTO categories_items(category_id, item_id) VALUES ($1, $2);', [r['category_id'], r['item_id']])
      end

    rescue PG::Error => err
      p [
          err.result.error_field( PG::Result::PG_DIAG_SEVERITY ),
          err.result.error_field( PG::Result::PG_DIAG_SQLSTATE ),
          err.result.error_field( PG::Result::PG_DIAG_MESSAGE_PRIMARY ),
          err.result.error_field( PG::Result::PG_DIAG_MESSAGE_DETAIL ),
          err.result.error_field( PG::Result::PG_DIAG_MESSAGE_HINT ),
          err.result.error_field( PG::Result::PG_DIAG_STATEMENT_POSITION ),
          err.result.error_field( PG::Result::PG_DIAG_INTERNAL_POSITION ),
          err.result.error_field( PG::Result::PG_DIAG_INTERNAL_QUERY ),
          err.result.error_field( PG::Result::PG_DIAG_CONTEXT ),
          err.result.error_field( PG::Result::PG_DIAG_SOURCE_FILE ),
          err.result.error_field( PG::Result::PG_DIAG_SOURCE_LINE ),
          err.result.error_field( PG::Result::PG_DIAG_SOURCE_FUNCTION ),
      ]
    end
    #connect to reliefdb_development database
  end

end
