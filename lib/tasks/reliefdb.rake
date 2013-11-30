namespace :reliefdb do

  desc "Imports data from legacy database to new one"
  task import_data: :environment do

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
                          password: 'call me postgres')
    
    begin  
      #categories
      res = cat_conn.exec('select * from categories')
      rdb_conn.exec('delete from categories')
      puts "categories started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO categories(id, description, created_at, updated_at, name) VALUES ($1, $2, $3, $4, $5);', [r['id'], r['notes'], r['created_at'], r['updated_at'], r['name']])
        puts "category insert: #{r['id']}"
      end
      puts "categories finished"
      #items
      res = cat_conn.exec('select * from items')
      rdb_conn.exec('delete from items')
      puts "items started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO items(id, description, created_at, updated_at, name, quantity) VALUES ($1, $2, $3, $4, $5, $6);', [r['id'], r['notes'] ? r['notes'].force_encoding('iso8859-1').encode('utf-8') : nil, r['created_at'], r['updated_at'], r['name'] ? r['name'].force_encoding('iso8859-1').encode('utf-8') : nil, r['qty_per_pallet']])
        puts "item insert: #{r['id']}"
      end
      puts "items finished"
      #categories_items
      res = cat_conn.exec('select * from categories_items')
      rdb_conn.exec('delete from categories_items')
      puts "categories_items started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO categories_items(category_id, item_id) VALUES ($1, $2);', [r['category_id'], r['item_id']])
        puts "categories_items insert: #{r['category_id']} - #{r['item_id']}"
      end
      puts "categories_items finished"
      #users
      res = cat_conn.exec('select * from users')
      rdb_conn.exec('delete from users')
      puts "users started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO users(id, username, email, first_name, last_name) VALUES ($1, $2, $3, $4, $5);', [r['id'], r['login'], r['email'], r['firstname'], r['lastname']])
        puts "users insert: #{r['id']}"
      end
      puts "users finished"
      #shelters
      res = cat_conn.exec('select * from shelters')
      rdb_conn.exec('delete from organizations;delete from facilities;')
      puts "shelters started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO organizations(id,name) VALUES ($1, $2);', [r['id'], r['organization']])
        rdb_conn.exec_params(%Q(INSERT INTO facilities(organization_id, 
                                                        website,
                                                        headquarters,
                                                        phone,
                                                        address,
                                                        contact_name,
                                                        created_at,
                                                        updated_at,
                                                        name, 
                                                        state, county, city,
                                                        dc, dc_population, dc_shelters, dc_more, 
                                                        mgt_phone, supply_phone, supply_contact_name, 
                                                        notes, zipcode, other_notes, latitude, longitude, 
                                                        red_cross_status, region, capacity, population, status, 
                                                        org_name, make_payable, facility_type, hours, loading_docks,
                                                        forklifts, workers, pallet_jacks, client_contact_name, 
                                                        client_contact_phone, client_contact_address, 
                                                        client_contact_email, waiting_list, areas_served, 
                                                        eligibility, is_fee_required, fee_amount, payment_forms, 
                                                        temp_perm, planned_enddate, fee_is_for, mission, 
                                                        internal_notes, clients_must_bring, fee_explaination, 
                                                        temp_perm_explaination, waiting_list_explaination,id) 
                                  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
                                          $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
                                          $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
                                          $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
                                          $41, $42, $43, $44, $45, $46, $47, $48, $49, $50,
                                          $51, $52, $53, $54, $55, $56, $57);), 
                                                        [r['id'], 
                                                        r['website'] ? r['website'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        true,
                                                        r['main_phone'] ? r['main_phone'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        r['address'] ? r['address'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        r['mgt_contact'] ? r['mgt_contact'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        r['created_at'],
                                                        r['updated_at'],
                                                        r['name'] ? r['name'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        r['state'] ? r['state'].force_encoding('iso8859-1').encode('utf-8') : nil, r['parish'] ? r['parish'].force_encoding('iso8859-1').encode('utf-8') : nil, r['town'] ? r['town'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                        r['dc'], r['dc_population'], r['dc_shelters'], r['dc_more'], 
                                                        r['mgt_phone'] ? r['mgt_phone'].force_encoding('iso8859-1').encode('utf-8') : nil, r['supply_phone'] ? r['supply_phone'].force_encoding('iso8859-1').encode('utf-8') : nil, r['supply_contact_name'] ? r['supply_contact_name'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['notes'] ? r['notes'].force_encoding('iso8859-1').encode('utf-8') : nil, r['zip'] ? r['zip'].force_encoding('iso8859-1').encode('utf-8') : nil, r['other_contacts'] ? r['other_contacts'].force_encoding('iso8859-1').encode('utf-8') : nil, r['latitude'], r['longitude'], 
                                                        r['red_cross_status'], r['region'] ? r['region'].force_encoding('iso8859-1').encode('utf-8') : nil, r['capacity'], r['current_population'], r['status'] ? r['status'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['organization'] ? r['organization'].force_encoding('iso8859-1').encode('utf-8') : nil, r['make_payable_to'] ? r['make_payable_to'].force_encoding('iso8859-1').encode('utf-8') : nil, r['facility_type'] ? r['facility_type'].force_encoding('iso8859-1').encode('utf-8') : nil, r['hours'] ? r['hours'].force_encoding('iso8859-1').encode('utf-8') : nil, r['loading_dock'],
                                                        r['forklift'], r['worker'], r['pallet_jack'], r['client_contact_name'] ? r['client_contact_name'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['client_contact_phone'], r['client_contact_address'] ? r['client_contact_address'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['client_contact_email'], r['waiting_list'], r['areas_served'] ? r['areas_served'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['eligibility'] ? r['eligibility'].force_encoding('iso8859-1').encode('utf-8') : nil, r['is_fee_required'] ? r['is_fee_required'].force_encoding('iso8859-1').encode('utf-8') : nil, r['fee_amount'], r['payment_forms'] ? r['payment_forms'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['temp_perm'] ? r['temp_perm'].force_encoding('iso8859-1').encode('utf-8') : nil, r['planned_enddate'], r['fee_is_for'] ? r['fee_is_for'].force_encoding('iso8859-1').encode('utf-8') : nil, r['mission'] ? r['mission'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['cat_notes'] ? r['cat_notes'].force_encoding('iso8859-1').encode('utf-8') : nil, r['clients_must_bring'] ? r['clients_must_bring'].force_encoding('iso8859-1').encode('utf-8') : nil, r['fee_explanation'] ? r['fee_explanation'].force_encoding('iso8859-1').encode('utf-8') : nil, 
                                                        r['temp_perm_explanation'] ? r['temp_perm_explanation'].force_encoding('iso8859-1').encode('utf-8') : nil, r['waiting_list_explanation'] ? r['waiting_list_explanation'].force_encoding('iso8859-1').encode('utf-8') : nil, r['id']])
        puts "shelter insert: #{r['id']}"
      end
      puts "shelters finished"
    #shelters_users
      res = cat_conn.exec('select * from shelters_users')
      rdb_conn.exec('delete from organizations_users')
      puts "organizations_users started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO organizations_users(organization_id, user_id) VALUES ($1, $2);', [r['shelter_id'], r['user_id']])
        puts "organizations_users insert: #{r['shelter_id']} - #{r['user_id']}"
      end
      puts "organizations_users finished"
    #conditions
    cat_conn.exec('delete from conditions where id = 70125 and lock_version = 0') #duplicate
    res = cat_conn.exec('select * from conditions')
    rdb_conn.exec('delete from resources;delete from items_resources;')
    puts "conditions started"
    res.each do |r|
      rdb_conn.exec_params('INSERT INTO items_resources(item_id, resource_id) VALUES ($1, $2);', [r['item_id'], r['id']])
      rdb_conn.exec_params('INSERT INTO resources(id, 
                                                  description, 
                                                  created_at, 
                                                  updated_at, 
                                                  facility_id, 
                                                  load_id, 
                                                  resource_type,
                                                  notes,
                                                  qty_needed,
                                                  surplus_individual,
                                                  surplus_crates,
                                                  qty_per_crate,
                                                  must_dispose_of_urgently,
                                                  urgency,
                                                  crate_preference,
                                                  can_buy_local,
                                                  packaged_as) VALUES ($1, $2, $3, $4, $5,
                                                                       $6, $7, $8, $9, $10,
                                                                       $11, $12, $13, $14, $15,
                                                                       $16, $17);', 
                                                  [r['id'], 
                                                  nil,
                                                  r['created_at'],
                                                  r['updated_at'],
                                                  r['shelter_id'],
                                                  r['load_id'],
                                                  r['type'] ? r['type'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                  r['notes'] ? r['notes'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                  r['qty_needed'],
                                                  r['surplus_individual'],
                                                  r['surplus_crates'],
                                                  r['qty_per_crate'],
                                                  r['must_dispose_of_urgently'],
                                                  r['urgency'],
                                                  r['crate_preference'],
                                                  r['can_buy_local'],
                                                  r['packaged_as'] ? r['packaged_as'].force_encoding('iso8859-1').encode('utf-8') : nil])
        puts "condition insert: #{r['id']}"
      end
       puts "conditions finished"
      #loads
      res = cat_conn.exec('select * from loads')
      rdb_conn.exec('delete from loads')
      puts "loads started"
      res.each do |r|
        rdb_conn.exec_params('INSERT INTO loads(id,
                                                created_at,
                                                updated_at,
                                                facility_id,
                                                info_source,
                                                notes,
                                                source_id,
                                                destination_id,
                                                title,
                                                trucker_name,
                                                truck_reg,
                                                status,
                                                ready_by,
                                                etd,
                                                eta,
                                                transport_avail,
                                                routing_type) VALUES ($1, $2, $3, $4, $5,
                                                                       $6, $7, $8, $9, $10,
                                                                       $11, $12, $13, $14, $15,
                                                                       $16, $17);', 
                                                [r['id'], 
                                                r['created_at'],
                                                r['updated_at'],
                                                r['source_id'],
                                                r['info_source'] ? r['info_source'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                r['notes'] ? r['notes'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                r['source_id'],
                                                r['destination_id'],
                                                r['title'] ? r['title'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                r['trucker_name'] ? r['trucker_name'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                r['truck_reg'] ? r['truck_reg'].force_encoding('iso8859-1').encode('utf-8') : nil,
                                                r['status'],
                                                r['ready_by'],
                                                r['etd'],
                                                r['eta'],
                                                r['transport_avail'],
                                                r['routing_type']])
        puts "load insert: #{r['id']}"
      end
      puts "loads finished"
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
