module Apocalypse
  module Models
    class Location < ::Sequel::Model
      def full_address
        "#{address}, #{zip} #{city}"
      end
    end
  end
end
