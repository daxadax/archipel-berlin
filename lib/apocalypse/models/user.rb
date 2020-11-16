module Apocalypse
  module Models
    class User < ::Sequel::Model
      def admin?
        !!admin
      end
    end
  end
end
