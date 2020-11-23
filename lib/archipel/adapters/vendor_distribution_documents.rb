module ArchipelBerlin
  module Adapters
    class VendorDistributionDocuments < Adapter
      def call
        orders.flat_map(&:items).group_by(&:vendor).each do |vendor, items|
          next if SKIPPED_VENDORS.include?(vendor.downcase)

          path = "./tmp/#{vendor.gsub(' ', '_').upcase}.pdf"
          title = "#{vendor} packing list"
          subtitles = [date, "#{items.map(&:quantity).sum} total items"]

          ::Services::PdfGenerator.new(path, title, subtitles).call do |pdf|
            items.group_by(&:delivery_route).each do |route_name, route_items|
              header_text = "#{route_name} - #{route_items.map(&:quantity).sum} ITEMS(S)\n\n".upcase
              pdf.text header_text, style: :bold, size: 14

              items_by_order_number = route_items.
                group_by(&:order_number).
                sort_by(&:first)

              items_by_order_number.each do |order_number, order_items|
                pdf.text "#{order_number} #{order_items.first.order_name}", style: :bold

                order_items.each do |item|
                  pdf.indent(3) do
                    pdf.formatted_text [
                      { text: "\u2610", font: "./fonts/DejaVuSans.ttf" },
                      { text: " #{item.quantity}x #{item.name}\n" }
                    ]
                  end
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

