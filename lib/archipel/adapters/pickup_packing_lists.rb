module ArchipelBerlin
  module Adapters
    class PickupPackingLists < Adapter
      def self.call(date)
        new(date).call
      end

      def call
        pickup_locations.each do |pickup_location|
          relevant_orders = Entities::Orders.at_pickup_location(orders, pickup_location)
          next unless relevant_orders.present?

          path = "./tmp/#{pickup_location.split.join('_')}_pickups.pdf"
          title = "Pickups for #{pickup_location} on #{date}\n\n"
          subtitle = "#{relevant_orders.all.count} ORDER(S)"

          ::Services::PdfGenerator.new(path, title, subtitle).call do |pdf|
            sorted_orders = relevant_orders.all.sort_by(&:order_number)
            sorted_orders.each do |order|
              write_order(pdf, order, order == sorted_orders.last)
            end
          end
        end
      end

      private

      def pickup_locations
        ArchipelBerlin::PICKUP_LOCATIONS
      end

      def write_order(pdf, order, last_order)
        pdf.text "#{order.order_number} #{order.name}\n"
        pdf.text "#{order.phone}\n"
        pdf.text "\n" # spacer
        write_items(pdf, order.items)
        pdf.text "\n#{'-' * 23}" unless last_order
        pdf.text "\n" # spacer
      end

      def write_items(pdf, items)
        items.group_by(&:vendor).each do |vendor, vendor_items|
          next if SKIPPED_VENDORS.include?(vendor)
          next unless vendor_items.any?

          pdf.text "#{vendor} (#{vendor_items.map(&:quantity).sum} items)\n"

          vendor_items.each do |item|
            pdf.indent(3) do
              pdf.formatted_text [
                { text: "\u2610", font: "./fonts/DejaVuSans.ttf" },
                { text: " #{item.quantity}x #{item.name}\n" }
              ]
            end
          end
        end
      end
    end
  end
end
