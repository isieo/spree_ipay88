module SpreeIpay88
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_ipay88'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

      config.after_initialize do |app|
        app.config.spree.payment_methods += [ Spree::BillingIntegration::Ipay88 ]
      end

    config.to_prepare &method(:activate).to_proc
  end
end
