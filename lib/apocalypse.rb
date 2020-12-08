require 'prawn'
require './lib/services/pdf_generator.rb'

# models
require './lib/apocalypse/models/user.rb'
require './lib/apocalypse/models/organization.rb'
require './lib/apocalypse/models/location.rb'
require './lib/apocalypse/models/contact.rb'
require './lib/apocalypse/models/delivery_request.rb'
require './lib/apocalypse/models/delivery.rb'
require './lib/apocalypse/models/delivery_item.rb'

# adapters
require './lib/apocalypse/adapters/delivery_pdf.rb'

module Apocalypse
end
