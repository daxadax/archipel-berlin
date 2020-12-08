module Apocalypse
  module Models
    class Organization < ::Sequel::Model
      one_to_many :delivery_requests

      def full_address
        "#{address}, #{zip} #{city}"
      end

      def locations
        Location.where(organization_id: id)
      end

      def previous_delivery_locations
        delivery_requests

        # temp
        Location.all
      end

      def users
        User.where(organization_id: id)
      end
    end
  end
end
