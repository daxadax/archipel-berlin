module ArchipelBerlin
  module Adapters
    class DeliveryPackingLists < Adapter
      def self.call(date)
        new(date).call
      end

      def call
        routes.each do |route|
          relevant_orders = Entities::Orders.in_delivery_route(orders, route)
          next unless relevant_orders.present?

          pdf_path = "./tmp/#{route}_deliveries.pdf"

          Prawn::Document.generate(pdf_path) do |pdf|
            pdf.font_families.update("Arial" => {
              :normal => "./fonts/arial.ttf",
              :bold => "./fonts/arial-bold.ttf"
            })
            pdf.font 'Arial'

            pdf.text "Deliveries for #{route} on #{date}\n\n"

            relevant_orders.by_zip_code.each do |zip_code, local_orders|
              pdf.text "#{zip_code} - #{local_orders.count} ORDER(S)\n\n", style: :bold

              orders_by_number = local_orders.sort_by(&:order_number)

              orders_by_number.each do |order|
                write_order(pdf, order, order == orders_by_number.last)
              end
            end
           end
        end
      end

      private

      def routes
        ArchipelBerlin::ROUTE_MAPPING.keys
      end

      def write_order(pdf, order, last_order)
        pdf.text "#{order.order_number} #{order.name}\n"
        pdf.text order.address + "\n"
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
