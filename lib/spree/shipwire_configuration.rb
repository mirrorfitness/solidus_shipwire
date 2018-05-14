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
        config.username     = self.username
        config.password     = self.password
        config.open_timeout = self.open_timeout
        config.timeout      = self.timeout
        config.endpoint     = self.endpoint
        config.logger       = self.logger
      end
    end
  end
end
