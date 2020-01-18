module Spree
  class ShipwireConfiguration < Preferences::Configuration
    preference :username,             :string,  default: nil
    preference :password,             :string,  default: nil
    preference :open_timeout,         :integer, default: 2
    preference :timeout,              :integer, default: 5
    preference :endpoint,             :string,  default: 'http://api.shipwire.com'
    preference :logger,               :string,  default: false
    preference :secret,               :string,  default: nil
    preference :default_warehouse_id, :string,  default: nil

    def setup_shipwire
      Shipwire.configure do |config|
        # Use get_preference to prevent self.timeout from resolving to Timeout#timeout on Ruby 2.7.0+
        config.username     = self.get_preference(:username)
        config.password     = self.get_preference(:password)
        config.open_timeout = self.get_preference(:open_timeout)
        config.timeout      = self.get_preference(:timeout)
        config.endpoint     = self.get_preference(:endpoint)
        config.logger       = self.get_preference(:logger)
      end
    end
  end
end
