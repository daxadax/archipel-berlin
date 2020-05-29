module ApocalypseAdmin
  module Models
    class ShopifyOrder < ::Sequel::Model
      def orders
        @orders ||= raw_data.group_by { |row| row['Name'] }.map do |order_number, items|
          ApocalypseAdmin::Entities::Order.new(items)
        end
      end

      # the orders parsed for a given day will be delivered the next day
      def report_date
        @report_date ||= (date + 1).to_s
      end

      def generate_reports
        ApocalypseAdmin::Commands::GenerateReports.call(date: date.to_s)
      end

      private

      def raw_data
        @raw_data ||= CSV.parse(csv_string, headers: true)
      end
    end
  end
end
