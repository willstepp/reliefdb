# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

Rails.root.to_s = "#{File.dirname(__FILE__)}/.." unless defined?(Rails.root.to_s)

unless defined?(Rails::Initializer)
  if File.directory?("#{Rails.root.to_s}/vendor/rails")
    require "#{Rails.root.to_s}/vendor/rails/railties/lib/initializer"
  else
    require 'rubygems'

    rails_gem_version =
      if defined? RAILS_GEM_VERSION
        RAILS_GEM_VERSION
      else
        File.read("#{File.dirname(__FILE__)}/environment.rb") =~ /^[^#]*RAILS_GEM_VERSION\s+=\s+'([\d.]+)'/
        $1
      end

    if rails_gem_version
      rails_gem = Gem.cache.search('rails', "=#{rails_gem_version}.0").sort_by { |g| g.version.version }.last

      if rails_gem
        gem "rails", "=#{rails_gem.version.version}"
        require rails_gem.full_gem_path + '/lib/initializer'
      else
        STDERR.puts %(Cannot find gem for Rails =#{rails_gem_version}.0:
    Install the missing gem with 'gem install -v=#{rails_gem_version} rails', or
    change environment.rb to define RAILS_GEM_VERSION with your desired version.
  )
        exit 1
      end
    else
      gem "rails"
      require 'initializer'
    end
  end

  Rails::Initializer.run(:set_load_path)
end
