module Apocalypse
  module Models
    class Location < ::Sequel::Model
      def full_address
        "#{address}, #{zip} #{city}"
      end

      def contacts
        Contact.where(location_id: id)
      end

      def pending_pickups
        DeliveryRequest.where(pickup_location_id: id)
      end
    end
  end
end
