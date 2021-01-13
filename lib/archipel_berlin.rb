require 'csv'
require 'prawn'
require './lib/services/pdf_generator.rb'

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
require './lib/archipel/commands/generate_packing_lists.rb'
require './lib/archipel/commands/generate_vendor_distribution.rb'
require './lib/archipel/commands/generate_lode_stijn_orders.rb'
require './lib/archipel/commands/generate_order_summary.rb'

# adapters
require './lib/archipel/adapters/adapter.rb'
require './lib/archipel/adapters/vendor_distribution_documents.rb'
require './lib/archipel/adapters/delivery_packing_lists.rb'
require './lib/archipel/adapters/pickup_packing_lists.rb'
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
  SBERG_ZIPCODES = [10777,10781,10823,10827,10965,10779,10783,10789,10829].freeze

  ROUTE_MAPPING = {
    albatross_catering: { tag: ['Catering'] },
    schöneberg: { tag: ['Schoneberg'] },
    friedrichshain: { zip_code: FHAIN_ZIPCODES },
    mitte: { zip_code: MITTE_ZIPCODES },
    kreuzberg: { zip_code: XBERG_ZIPCODES },
    neukölln: { zip_code: NKOLN_ZIPCODES },
    # schöneberg: { zip_code: SBERG_ZIPCODES }
  }

  PICKUP_LOCATIONS = [
    'ISLAHUB',
    'ROCKET HUB',
    'ALBATROSS HUB',
    'ARCHI HUB',
    'HALASCHES HUB',
    'HERBIE HUB'
  ]
end
