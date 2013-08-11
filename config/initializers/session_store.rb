# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_2311_session',
  :secret      => 'eaa5cc5564ca4a114df1fc0978c29438697ef1c74e2d0170b35619e378c7376d7cffde5a54439afd141bedfd1537e035ac510e7b06c134f012808c933838149b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
