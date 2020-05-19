module ApocalypseAdmin
  module Adapters
    class OrderSummary < Adapter
      def call
        Prawn::Document.generate("./tmp/#{date}_order_information.pdf") do |pdf|
          pdf.font_families.update("Arial" => {
            :normal => "./fonts/arial.ttf",
            :bold => "./fonts/arial-bold.ttf"
          })
          pdf.font 'Arial'

          pdf.text "Order Information for #{date}\n\n", style: :bold
          pdf.text "Orders #{order_numbers.first} - #{order_numbers.last}\n"
          pdf.text "First order: #{order_times.first}\n"
          pdf.text "Last order: #{order_times.last}\n\n"

          pdf.text "#{orders.count} total orders in #{zip_codes.count} zip codes\n\n", style: :bold

          orders_by_zip_code = Entities::Orders.new(orders).by_zip_code
          top_five_zips = orders_by_zip_code.sort_by { |k, v| v.count }.reverse.first(5)
          top_five_zips.each.with_index do |(zip_code, orders), index|
            pdf.text "#{index + 1}. #{zip_code} - #{orders.count} orders\n"
          end

          pdf.text "\n" # spacer

          orders.flat_map(&:items).group_by(&:vendor).each do |vendor, items|
            pdf.text "#{items.count} items ordered from #{vendor}\n", style: :bold

            sorted_by_route = items.group_by(&:delivery_route).sort_by { |k, v| v.count }.reverse
            sorted_by_route.each do |destination_hub, route_items|
              pdf.text "#{route_items.count} items ordered in #{destination_hub}\n"
            end

            pdf.text "\n" # spacer
          end
        end

        print "Order Information generated successfully\n"
      end

      private

      def zip_codes
        @zip_codes ||= orders.map(&:zip_code).uniq
      end

      def order_numbers
        @order_numbers ||= orders.map(&:order_number).sort
      end

      def order_times
        @order_times ||= orders.map(&:order_timestamp).sort
      end
    end
  end
end
