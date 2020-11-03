module ArchipelBerlin
  module Commands
    class GeneratePackingLists < Command
      def call
        ArchipelBerlin::Adapters::PickupPackingLists.call(date)
        ArchipelBerlin::Adapters::DeliveryPackingLists.call(date)
      end
    end
  end
end
