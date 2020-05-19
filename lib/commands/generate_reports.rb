module ApocalypseAdmin
  module Commands
    class GenerateReports < Command
      def call
        # ensure target directory is empty
        FileUtils.rm_f Dir.glob('./tmp/*')

        # generate all reports
        Commands::GenerateVendorDistribution.call(date: date)
        Commands::GenerateHubPackingLists.call(date: date)
        Commands::GenerateLodeStijnOrders.call(date: date)

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
