module Apocalypse
  module Models
    class DeliveryRequest < ::Sequel::Model
      def dropoff?
        !!dropoff_hub
      end

      def acknowledged?
        !!acknowledged_at
      end

      def pickup_location
        @pickup_location ||= Location[pickup_location_id]
      end

      def invoice_location
        @invoice_location ||= Location[invoice_location_id]
      end

      def deliveries
        @deliveries ||= Delivery.where(delivery_request_id: id)
      end

      def total_delivery_weight
        deliveries.flat_map { |d| d.items.all.map(&:weight_in_grams) }.sum
      end
    end
  end
end
