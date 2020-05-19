module ApocalypseAdmin
  module Commands
    class GenerateVendorDistribution < Command
      def call
        Adapters::VendorDistributionDocuments.call(date)
      end
    end
  end
end
