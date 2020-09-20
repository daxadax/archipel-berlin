module ArchipelBerlin
  module Adapters
    class Adapter
      SKIPPED_VENDORS = ['lode & stijn'].freeze

      def self.call(date)
        new(date).call
      end

      def initialize(date)
        @date = date
        @orders = ArchipelBerlin::Models::ShopifyOrder.find(date: date.to_s).orders
      end

      def call
        raise NotImplementedError
      end

      private
      attr_reader :date, :orders
    end
  end
end
