module ArchipelBerlin
  module Adapters
    class HubPackingLists < Adapter
      def self.call(date, type)
        new(date).call(type)
      end

      def call(type)
        routes.each do |hub|
          hub_orders = Entities::Orders.in_route(orders, hub)
          next unless hub_orders.present?

          # TODO: orders.send(:orders) is gross, yuck.
          orders_by_type = Entities::Orders.by_type(hub_orders.send(:orders), type)
          next unless orders_by_type.present?

          Prawn::Document.generate("./tmp/#{hub}_#{type}.pdf") do |pdf|
            pdf.font_families.update("Arial" => {
              :normal => "./fonts/arial.ttf",
              :bold => "./fonts/arial-bold.ttf"
            })
            pdf.font 'Arial'

            pdf.text "#{type} packing list for #{hub} on #{date}\n\n"

            orders_by_type.by_zip_code.each do |zip_code, orders|
              pdf.text "#{zip_code} - #{orders.count} ORDER(S)\n\n", style: :bold

              orders_by_number = orders.sort_by(&:order_number)

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
