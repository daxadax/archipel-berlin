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
require './lib/archipel/models/shopify_order.rb'

# entities
require './lib/archipel/entities/orders.rb'
require './lib/archipel/entities/order.rb'
require './lib/archipel/entities/item.rb'

# services
require './lib/archipel/services/generate_zip_file.rb'

# commands
require './lib/archipel/commands/command.rb'
require './lib/archipel/commands/generate_reports.rb'
require './lib/archipel/commands/generate_hub_packing_lists.rb'
require './lib/archipel/commands/generate_vendor_distribution.rb'
require './lib/archipel/commands/generate_lode_stijn_orders.rb'
require './lib/archipel/commands/generate_order_summary.rb'

# adapters
require './lib/archipel/adapters/adapter.rb'
require './lib/archipel/adapters/vendor_distribution_documents.rb'
require './lib/archipel/adapters/hub_packing_lists.rb'
require './lib/archipel/adapters/lode_stijn_orders.rb'
require './lib/archipel/adapters/order_summary.rb'

module ArchipelBerlin
  # There is one zip code that got transferred from NKOLN to XBERG
  # so there is a slightly gross regex fix here for that.
  # If more such fixes are required, this matching system should change
  FHAIN_ZIPCODES = [/102\d{2}/].freeze
  MITTE_ZIPCODES = [/101\d{2}/, /104\d{2}/].freeze
  XBERG_ZIPCODES = [/109\d{2}/, /12047/].freeze
  NKOLN_ZIPCODES = [/120\d{2}/, /^((?!12047).)*$/].freeze

  ROUTE_MAPPING = {
    albatross_catering: { tag: ['Catering'] },
    friedrichshain: { zip_code: FHAIN_ZIPCODES },
    mitte: { zip_code: MITTE_ZIPCODES },
    kreuzberg: { zip_code: XBERG_ZIPCODES },
    neukölln: { zip_code: NKOLN_ZIPCODES }
  }
end
