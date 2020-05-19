module ApocalypseAdmin
  module Commands
    class GenerateLodeStijnOrders < Command
      def call
        Adapters::LodeStijnOrders.call(date)
      end
    end
  end
end
