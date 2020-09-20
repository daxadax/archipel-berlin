module ArchipelBerlin
  module Commands
    class GenerateHubPackingLists < Command
      def call
        ArchipelBerlin::Adapters::HubPackingLists.call(date, :delivery)
        ArchipelBerlin::Adapters::HubPackingLists.call(date, :pickup)
      end
    end
  end
end
