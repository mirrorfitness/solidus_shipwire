module SolidusShipwire
  module ShipwireObjects
    class ReturnAuthorization < Spree::ReturnAuthorization::ShipwireObject
      def status
        @attrs[:status]
      end
    end
  end
end
