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

          pdf_path = "./tmp/#{pickup_location.split.join('_')}_pickups.pdf"

          Prawn::Document.generate(pdf_path) do |pdf|
            pdf.font_families.update("Arial" => {
              :normal => "./fonts/arial.ttf",
              :bold => "./fonts/arial-bold.ttf"
            })
            pdf.font 'Arial'

            pdf.text "Pickups for #{pickup_location} on #{date}\n\n"
            pdf.text "#{relevant_orders.all.count} ORDER(S)\n\n", style: :bold

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

          pdf.text " - #{vendor} (#{vendor_items.map(&:quantity).sum} items)\n"

          vendor_items.each { |i| pdf.text " --- #{i.quantity}x #{i.name}\n" }
        end
      end
    end
  end
end
