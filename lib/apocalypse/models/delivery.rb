module Apocalypse
  module Models
    class Delivery < ::Sequel::Model
      def location
        @location ||= Location[location_id]
      end

      def delivery_request
        @delivery_request ||= DeliveryRequest[delivery_request_id]
      end

      def items
        @items ||= DeliveryItem.where(delivery_id: id)
      end
    end
  end
end
