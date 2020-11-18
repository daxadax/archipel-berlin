module Apocalypse
  module Models
    class Organization < ::Sequel::Model
      def locations
        Location.where(organization_id: id)
      end
    end
  end
end
