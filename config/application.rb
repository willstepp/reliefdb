require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Reliefdb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register 'application/pdf', :pdf

#ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address  => "smtp.gmail.com",
  :port  => 587, 
  :domain  => "gmail.com",
  :user_name  => "willstepp@gmail.com",
  :password  => "Falliscoming2013",
  :authentication  => "plain",
  :enable_starttls_auto => true
} 

# Include your application configuration below
#ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:prefix] = "cat_#{RAILS_ENV}_sess."
#ActionController::Base.perform_caching = true
#ActionController::Base.cache_store = :file_store, "tmp/cat_#{RAILS_ENV}_frag"

# Salted Login Generation Stuff
require 'config/environments/localization_environment'
require 'localization'
Localization::load_localized_strings

$DBADMIN = "dbadmin@citizenactionteam.org"
require 'config/environments/user_environment'

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
module ActionView
  module Helpers
    module NumberHelper
      module_function :number_to_currency
    end
  end
end

unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end
