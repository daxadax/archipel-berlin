module Apocalypse
  module Models
    class User < ::Sequel::Model
      one_to_many :delivery_requests

      def admin?
        !!administrator
      end

      def organization
        Apocalypse::Models::Organization[organization_id]
      end
    end
  end
end
