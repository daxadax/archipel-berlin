module ApocalypseAdmin
  module Commands
    class GenerateOrderSummary < Command
      def call
        ApocalypseAdmin::Adapters::OrderSummary.call(date)
      end
    end
  end
end
