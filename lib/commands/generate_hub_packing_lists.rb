module ApocalypseAdmin
  module Commands
    class GenerateHubPackingLists < Command
      def call
        ApocalypseAdmin::Adapters::HubPackingLists.call(date, :delivery)
        ApocalypseAdmin::Adapters::HubPackingLists.call(date, :pickup)
      end
    end
  end
end
