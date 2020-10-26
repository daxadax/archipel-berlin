module Apocalypse
  module Adapters
    class DeliveryPdf
      def self.call(delivery_request_id)
        new(delivery_request_id).call
      end

      def initialize(delivery_request_id)
        @delivery_request = Apocalypse::Models::DeliveryRequest[delivery_request_id]
      end

      def call
        path = "./tmp/delivery_request-#{delivery_request.id}.pdf"

        Prawn::Document.generate(path) do |pdf|
          pdf.font_families.update("Arial" => {
            :normal => "./fonts/arial.ttf",
            :bold => "./fonts/arial-bold.ttf"
          })
          pdf.font 'Arial'

          pdf.text "Delivery Request\n",
            style: :bold, align: :center, size: 18
          pdf.text delivery_request.created_at.strftime("%d %B %Y, %H:%M"),
            style: :bold, align: :center
          pdf.text "\n"

          pdf.bounding_box([0, 660], width: 250, height: 100) do
            pdf.move_down 10
            pdf.text "Pickup details:", align: :center
            pdf.move_down 5
            pdf.indent(10) { pdf.text pickup_details }
            pdf.stroke_bounds
          end

          pdf.bounding_box([300, 660], width: 250, height: 100) do
            pdf.move_down 10
            pdf.text "Invoice details:", align: :center
            pdf.move_down 5
            pdf.indent(10) { pdf.text invoice_details }
            pdf.stroke_bounds
          end

          pdf.text "\n"

          pdf.text "Deliveries:\n\n"

          delivery_request.deliveries.each_with_index do |delivery, index|
            available_from_timestamp = delivery.available_from.strftime("%d %B %Y, %H:%M")

            pdf.text "#{index + 1}. #{delivery.location.name.upcase}", style: :bold

            pdf.move_down 5

            pdf.indent(15) do
              pdf.text "Address: #{delivery.location.full_address}\n\n"
              pdf.text "Available for pickup from: #{available_from_timestamp}\n"
              pdf.text "Notes: #{delivery.notes}\n\n"

              pdf.text "Items:\n"
              delivery.items.each do |item|
                item_text = "--- #{item.name} (#{item.weight_in_grams.to_f / 1000}kg) "
                pdf.text item_text + ( item.notes.empty? ? '' : item.notes ) + "\n"
              end
            end

            pdf.text "\n"
          end
        end

        path
      end

      private
      attr_reader :delivery_request

      def pickup_details
        pickup_location = delivery_request.pickup_location

        pickup_location.name + "\n" +
        pickup_location.full_address + "\n" +
        "Contact: #{pickup_location.contact} \n" +
        pickup_location.phone
      end

      def invoice_details
        invoice_location = delivery_request.invoice_location

        invoice_location.name + "\n" +
        invoice_location.full_address + "\n" +
        "Contact: #{invoice_location.contact} \n" +
        invoice_location.email
      end
    end
  end
end
