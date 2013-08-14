# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '1.1.6'
# RAILS_GEM_VERSION = '1.2.2' unless defined? RAILS_GEM_VERSION
RAILS_GEM_VERSION = '1.1.6' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{Rails.root.to_s}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:prefix] = "cat_#{RAILS_ENV}_sess."
ActionController::Base.perform_caching = true
#ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::FileStore.new("/tmp/cat_#{RAILS_ENV}_frag")
ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::FileStore.new("tmp/cat_#{RAILS_ENV}_frag")

# Salted Login Generation Stuff
require 'environments/localization_environment'
require 'localization'
Localization::load_localized_strings

$DBADMIN = "dbadmin@citizenactionteam.org"
require 'environments/user_environment'

require "model_extensions"

$DEFAULT_MAP_CENTER = [-90.074063, 29.954197]
$MAPWIDTH = "700"
$MAPHEIGHT = "600"
$ZOOM_FAR = 10
$ZOOM_CLOSE = 9
$ZOOM_VERYCLOSE = 7

def html_escape(s)
  s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
end
alias h html_escape

def tf(str)
  h(str).strip.gsub("\n", "<BR>")
end

def sqlsafe(str)
  ActiveRecord::Base.connection.quote_string(str)
end
