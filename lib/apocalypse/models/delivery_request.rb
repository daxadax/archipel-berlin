module Apocalypse
  module Models
    class DeliveryRequest < ::Sequel::Model
      many_to_one :created_by, class: 'Apocalypse::Models::User'.to_sym
      many_to_one :organization

      def status
        return 'confirmed' if acknowledged?
        return 'rejected' if rejected?

        'pending'
      end

      def dropoff?
        !!dropoff_hub
      end

      def acknowledged?
        !!acknowledged_at
      end

      def rejected?
        # TODO: should also include a reason probably?
        false
      end

      def pickup_location
        @pickup_location ||= Location[pickup_location_id]
      end

      def pickup_contact
        @pickup_contact ||= Contact[pickup_contact_id]
      end

      def invoice_location
        @invoice_location ||= Location[invoice_location_id] || Organization[invoice_location_id] || Organization[organization_id]
      end

      def deliveries
        @deliveries ||= Delivery.where(delivery_request_id: id).all
      end

      def total_delivery_weight
        weight = deliveries.flat_map { |d| d.items.all.map(&:weight_in_grams) }.sum
        weight / 1000.to_f
      end
    end
  end
end
