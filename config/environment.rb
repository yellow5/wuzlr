# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
end

def log_to(stream=$stdout)
  ActiveRecord::Base.logger = Logger.new(stream)
  ActiveRecord::Base.connection_pool.clear_reloadable_connections!
end

DO_NOT_REPLY = "donotreply@wuzlr.com"
