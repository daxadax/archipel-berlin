module ApocalypseAdmin
  module Adapters
    class VendorDistributionDocuments < Adapter
      def call
        orders.flat_map(&:items).group_by(&:vendor).each do |vendor, items|
          next if SKIPPED_VENDORS.include?(vendor.downcase)

          # NOTE: catch for missing vendors
          # TODO: should print to dashboard rather than console
          if vendor.nil?
            items.each do |item|
              print "\n### INFO ### no vendor found for item #{item.order_number}\n\n"
            end
            next
          end

          document_path = "./tmp/#{vendor.gsub(' ', '_').upcase}.pdf"

          Prawn::Document.generate(document_path) do |pdf|
            pdf.font_families.update("Arial" => {
              :normal => "./fonts/arial.ttf",
              :bold => "./fonts/arial-bold.ttf"
            })
            pdf.font 'Arial'

            pdf.text "Packing list for #{vendor} on #{date}\n", style: :bold
            pdf.text "#{items.map(&:quantity).sum} total items\n\n"

            items.group_by(&:delivery_route).each do |route_name, route_items|
              header_text = "#{route_name} - #{route_items.map(&:quantity).sum} ITEMS(S)\n\n".upcase
              pdf.text header_text, style: :bold, size: 14

              items_by_order_number = route_items.
                group_by(&:order_number).
                sort_by(&:first)

              items_by_order_number.each do |order_number, order_items|
                pdf.text "#{order_number} #{order_items.first.order_name}", style: :bold

                order_items.each do |item|
                  pdf.text "#{item.quantity}x #{item.name}"
                end

                pdf.text "\n" # spacer
              end

              pdf.text "\n" # spacer
            end
          end
        end
      end
    end
  end
end

