module Apocalypse
  module Models
    class DeliveryRequest < ::Sequel::Model
      def dropoff?
        !!dropoff_hub
      end

      def acknowledged?
        !!acknowledged_at
      end

      def delivery_locations
        JSON.parse(delivery_locations_json)
      end
    end
  end
end
