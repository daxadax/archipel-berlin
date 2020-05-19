module ApocalypseAdmin
  module Entities
    class Orders
      AVAILABLE_ORDER_TYPES = %i[delivery pickup]

      def self.in_route(orders, route_name)
        new(orders.select { |order| order.delivery_route == route_name })
      end

      def self.by_type(orders, type)
        raise NotImplementedError unless AVAILABLE_ORDER_TYPES.include?(type.downcase)

        new(orders.select { |order| order.send("for_#{type}?".to_sym) })
      end

      def initialize(orders)
        @orders = orders
      end

      def total_items
        @total_items = orders.flat_map { |order| order.items.map(&:quantity) }.sum
      end

      def by_zip_code
        orders.sort_by(&:zip_code).group_by(&:zip_code)
      end

      def present?
        orders.any?
      end

      private
      attr_reader :orders
    end
  end
end
