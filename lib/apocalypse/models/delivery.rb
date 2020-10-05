module Apocalypse
  module Models
    class Delivery < ::Sequel::Model
      def location
        @location ||= Location[location_id]
      end

      def items
        @items ||= DeliveryItem.where(delivery_id: id)
      end
    end
  end
end
