require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

## Load the specific APM agent
# We rely on DOTENV to load the environment variables
# We need these environment variables to load the specific APM agent
Dotenv::Railtie.load

if ENV.fetch('NEW_RELIC_LICENSE_KEY', false).present?
  require 'newrelic-sidekiq-metrics'
  require 'newrelic_rpm'
end

if ENV.fetch('SENTRY_DSN', false).present?
  require 'sentry-ruby'
  require 'sentry-rails'
  require 'sentry-sidekiq'
end

require 'elastic-apm' if ENV.fetch('ELASTIC_APM_SECRET_TOKEN', false).present?

module WoofedCrm
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    if Rails.env.production?
      Rails.application.routes.default_url_options = { host: ENV['HOST_URL'], protocol: 'https' }
    elsif Rails.env.development?
      Rails.application.routes.default_url_options = { host: ENV['HOST_URL'], protocol: 'http' }
    end

    # Disable serving static files from the `/public` folder by default since
    # Apache or NGINX already handles this.
    config.public_file_server.enabled = true

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = true
    config.serve_static_assets = true


    # Location and Timezone
    config.i18n.default_locale = 'pt-BR'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales','**' ,'*.{rb,yml}').to_s]
    config.time_zone = 'Brasilia'
    config.host = nil

    config.assets.css_compressor = nil
  end
end
