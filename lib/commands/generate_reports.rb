module ApocalypseAdmin
  module Commands
    class GenerateReports < Command
      def call
        # ensure target directory is empty
        FileUtils.rm_f Dir.glob('./tmp/*')

        # TODO: could be more efficient here with db calls.
        # currently this is passing the date to each command,
        # and each command is looking up the orders for that date.

        # generate all reports
        Commands::GenerateVendorDistribution.call(date: date)
        Commands::GenerateHubPackingLists.call(date: date)
        Commands::GenerateLodeStijnOrders.call(date: date)
        Commands::GenerateOrderSummary.call(date: date)

        target_path = "./tmp/#{date}.zip"

        # zip everything and save it
        Services::ZipFileGenerator.call('./tmp/', target_path)

        # save the zip file
        Models::ShopifyOrder.find(date: date).update(
          generated_reports: File.read(target_path)
        )

        # clean up
        FileUtils.rm_f Dir.glob('./tmp/*')
      end
    end
  end
end
