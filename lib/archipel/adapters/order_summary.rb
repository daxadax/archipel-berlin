module ArchipelBerlin
  module Adapters
    class OrderSummary < Adapter
      def call
        path = "./tmp/#{date}_order_information.pdf"
        title = "Order Summary"
        subtitles = [date, "Orders #{order_numbers.first} - #{order_numbers.last}"]

        ::Services::PdfGenerator.new(path, title, subtitles).call do |pdf|
          pdf.text "First order: #{order_times.first}\n"
          pdf.text "Last order: #{order_times.last}\n\n"

          pdf.text "#{orders.count} total orders in #{zip_codes.count} zip codes\n\n", style: :bold

          orders_by_zip_code.first(5).each.with_index do |(zip_code, order_count), index|
            pdf.text "#{index + 1}. #{zip_code} - #{order_count} orders\n"
          end

          pdf.text "\n" # spacer

          items.group_by(&:vendor).each do |vendor, vendor_items|
            pdf.text "#{vendor_items.count} items ordered from #{vendor}\n", style: :bold

            sorted_by_route = vendor_items.
              group_by(&:delivery_route).
              sort_by { |k, v| v.count }.
              reverse

            sorted_by_route.each do |destination_hub, route_items|
              pdf.text "#{route_items.count} items ordered in #{destination_hub}\n"
            end

            pdf.text "\n" # spacer
          end
        end

        ArchipelBerlin::Models::ShopifyOrder.find(date: date.to_s).update(
          order_summary: order_summary.to_json
        )

        print "Order Information generated successfully\n"
      end

      private

      def zip_codes
        @zip_codes ||= orders.map(&:zip_code).uniq
      end

      # you ugly
      def orders_by_zip_code
        @orders_by_zip_code ||= Entities::Orders.new(orders).
          by_zip_code.
          inject({}) do |result, (zip_code, orders)|
            result[zip_code] = orders.count
            result
          end.
          sort_by(&:last).
          reverse
      end

      def items_by_vendor
        @items_by_vendor ||= items.group_by(&:vendor).
          inject({}) do |result, (vendor, orders)|
            result[vendor] = orders.count
            result
          end.
          sort_by(&:last).
          reverse
      end

      def orders_by_route
        @orders_by_route ||= orders.select(&:for_delivery?).
          group_by(&:delivery_route).
          inject({}) do |result, (route, orders)|
            result[route] = orders.count
            result
          end.
          sort_by(&:last).
          reverse
      end

      def pickup_orders_by_hub
        @pickup_orders_by_hub ||= orders.select(&:for_pickup?).
          group_by(&:pickup_location).
          inject({}) do |result, (hub, orders)|
            result[hub] = orders.count
            result
          end.
          sort_by(&:last).
          reverse
      end

      def order_numbers
        @order_numbers ||= orders.map(&:order_number).sort
      end

      def order_times
        @order_times ||= orders.map(&:order_timestamp).sort
      end

      def items
        @items ||= orders.flat_map(&:items)
      end

      # TODO: should be a separate class maybe?
      def order_summary
        {
          total_orders: orders.count,
          zip_codes: zip_codes.uniq,
          vendors: items.map(&:vendor).uniq,
          routes: items.map(&:delivery_route).uniq,
          orders_by_zip_code: orders_by_zip_code,
          items_by_vendor: items_by_vendor,
          orders_by_route: orders_by_route,
          orders_by_hub: pickup_orders_by_hub
        }
      end
    end
  end
end
