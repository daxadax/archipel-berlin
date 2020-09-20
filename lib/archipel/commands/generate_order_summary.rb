module ArchipelBerlin
  module Commands
    class GenerateOrderSummary < Command
      def call
        ArchipelBerlin::Adapters::OrderSummary.call(date)
      end
    end
  end
end
