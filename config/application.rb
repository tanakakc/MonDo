require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Apps30
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
     config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
     config.i18n.default_locale = :ja
     
    # wheneverを使ったバッチ処理のために、libディレクトリのファイルパス設定
     config.autoload_paths += %W(#{config.root}/lib)
     config.autoload_paths += Dir["#{config.root}/lib/**/"]
     
    #自前で用意したjsファイルを読み込む
     config.assets.precompile += ['*.js', '*.css']
     config.assets.initialize_on_precompile = false
     config.assets.compress = true
    
    # Add the fonts path
     config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Precompile additional assets
     config.assets.precompile += %w( .svg .eot .woff .ttf )
  end
end
