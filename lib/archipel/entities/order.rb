module ArchipelBerlin
  module Entities
    class Order
      def initialize(data)
        @data = data
      end

      # format { route_name: [%r102xx, %r104xx] }
      def delivery_route
        @delivery_route ||= determine_delivery_route
      end

      def pickup_location
        return unless for_pickup?

        (tags & ArchipelBerlin::PICKUP_LOCATIONS).first
      end

      def for_delivery?
        !for_pickup?
      end

      def for_pickup?
        tags.include?('Pickup Order')
      end

      def name
        @name ||= collect('Shipping Name', 'Billing Name')
      end

      def email
        collect('Email')
      end

      def phone
        collect('Shipping Phone', 'Phone')&.gsub(/\D/, "")
      end

      def address
        address_two = collect('Shipping Address2', 'Billing Address2')
        base = "#{collect('Shipping Address1', 'Billing Address1')}, "
        base += "#{address_two}, " if address_two
        base += "#{zip_code} #{city}"
      end

      def zip_code
        @zip_code ||= collect('Shipping Zip', 'Billing Zip').gsub(/\D/, '')
      end

      def city
        @city ||= collect('Shipping City', 'Billing City')
      end

      def street
        @street ||= collect('Shipping Street', 'Billing Street')
      end

      def items
        @items ||= generate_order_items
      end

      def shipping_costs
        collect('Shipping')
      end

      def order_timestamp
        collect('Created at')
      end

      def order_number
        collect('Name')
      end

      def tags
        @tags ||= collect('Tags').split(', ')
      end

      private
      attr_reader :data

      def generate_order_items
        data.map { |row| Entities::Item.new(row, delivery_route, name) }
      end

      def determine_delivery_route
        result = ArchipelBerlin::ROUTE_MAPPING.detect do |route_name, matchers|
          matchers.any? do |property, matchers|
            case property
            when :tag
              matchers.any? { |matcher| tags.include?(matcher) }
            when :zip_code
              matchers.any? do |matcher|
                zip_code.match?(matcher)
                # zip_code.to_i == matcher if matcher.class.name == 'Integer'
              end
            end
          end
        end

        if result.nil?
          print "WARNING: unknown delivery route for order ##{order_number}\n"
          :outside_delivery_zone
        else
          result.first
        end
      end

      def collect(key, backup_key = nil)
        filled = data.detect { |row| row[key] }

        if filled.nil?
          return collect(backup_key) unless backup_key.nil?
          return nil
        end

        filled[key]
      end
    end
  end
end
