module ApocalypseAdmin
  module Models
    class ShopifyOrder < ::Sequel::Model
      def orders
        @orders ||= raw_data.group_by { |row| row['Name'] }.map do |order_number, items|
          ApocalypseAdmin::Entities::Order.new(items)
        end
      end

      private

      def raw_data
        @raw_data ||= CSV.parse(csv_string, headers: true)
      end
    end
  end
end
