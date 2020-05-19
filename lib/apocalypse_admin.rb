print "##############################\n\n"
print "Using DATABASE:  #{ENV['DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create

require 'csv'
require 'prawn'

# models
require './lib/models/shopify_order.rb'

# entities
require './lib/entities/orders.rb'
require './lib/entities/order.rb'
require './lib/entities/item.rb'

# services
require './lib/services/generate_zip_file.rb'

# commands
require './lib/commands/command.rb'
require './lib/commands/generate_reports.rb'
require './lib/commands/generate_hub_packing_lists.rb'
require './lib/commands/generate_vendor_distribution.rb'
require './lib/commands/generate_lode_stijn_orders.rb'
require './lib/commands/generate_order_summary.rb'

# adapters
require './lib/adapters/adapter.rb'
require './lib/adapters/vendor_distribution_documents.rb'
require './lib/adapters/hub_packing_lists.rb'
require './lib/adapters/lode_stijn_orders.rb'
require './lib/adapters/order_summary.rb'

module ApocalypseAdmin
  # There is one zip code that got transferred from NKOLN to XBERG
  # so there is a slightly gross regex fix here for that.
  # If more such fixes are required, this matching system should change
  FHAIN_ZIPCODES = [/102\d{2}/].freeze
  MITTE_ZIPCODES = [/101\d{2}/, /104\d{2}/].freeze
  XBERG_ZIPCODES = [/109\d{2}/, /12047/].freeze
  NKOLN_ZIPCODES = [/120\d{2}/, /^((?!12047).)*$/].freeze

  ZIP_CODE_MAPPING = {
    friedrichshain: FHAIN_ZIPCODES,
    mitte: MITTE_ZIPCODES,
    kreuzberg: XBERG_ZIPCODES,
    neukölln: NKOLN_ZIPCODES
  }
end
