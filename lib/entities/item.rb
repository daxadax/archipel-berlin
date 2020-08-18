module ArchipelBerlin
  module Entities
    class Item
      attr_reader :delivery_route, :order_name

      def initialize(data, delivery_route, order_name)
        @data = data
        @delivery_route = delivery_route
        @order_name = order_name
      end

      def vendor
        data['Vendor']
      end

      def quantity
        data['Lineitem quantity'].to_i
      end

      def name
        data['Lineitem name']
      end

      def order_number
        data['Name']
      end

      private
      attr_reader :data
    end
  end
end
