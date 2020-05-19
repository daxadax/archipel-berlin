module ApocalypseAdmin
  module Commands
    class Command
      def self.call(date:)
        new(date).call
      end

      def initialize(date)
        @date = date
      end

      def call
        raise NotImplementedError
      end

      private
      attr_reader :date
    end
  end
end
