module ArchipelBerlin
  module Adapters
    class LodeStijnOrders < Adapter
      RELEVANT_VENDOR = "lode & stijn"

      def call
        # only packed on thursdays and fridays
        target_date = Date.parse(date)
        return unless target_date.thursday? || target_date.friday?
        return if orders.empty?

        relevant_orders = orders.select do |order|
          order.items.map { |i| i.vendor.downcase }.include?(RELEVANT_VENDOR)
        end

        return if relevant_orders.empty?

        Prawn::Document.generate("./tmp/LODE-STIJN_deliveries.pdf") do |pdf|
          pdf.font_families.update("Arial" => {
            :normal => "./fonts/arial.ttf",
            :bold => "./fonts/arial-bold.ttf"
          })
          pdf.font 'Arial'

          pdf.text "Packing list for LODE-STIJN on #{date}\n\n"

          Entities::Orders.new(relevant_orders).by_zip_code.each do |zip_code, orders|
            pdf.text "#{zip_code} - #{orders.count} ORDER(S)\n\n", style: :bold

            orders_by_number = orders.sort_by(&:order_number)

            orders_by_number.each do |order|
              write_order(pdf, order, order == orders_by_number.last)
            end
          end
        end
      end

      private

      def write_order(pdf, order, last_order)
        pdf.text "#{order.order_number} #{order.name}\n"
        pdf.text order.address + "\n"
        pdf.text "#{order.phone}\n" unless order.phone.nil?
        pdf.text "\n" # spacer
        write_items(pdf, order.items)
        pdf.text "\n#{'-' * 23}" unless last_order
        pdf.text "\n" # spacer
      end

      def write_items(pdf, items)
        items.group_by(&:vendor).each do |vendor, vendor_items|
          next unless vendor == RELEVANT_VENDOR
          next unless vendor_items.any?

          pdf.text "#{vendor_items.map(&:quantity).sum} LODE/STIJN box/es\n"
        end
      end
    end
  end
end
