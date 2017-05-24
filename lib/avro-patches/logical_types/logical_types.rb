require 'date'

module Avro
  module LogicalTypes
    module IntDate
      EPOCH_START = Date.new(1970, 1, 1)

      def self.encode(date)
        (date - EPOCH_START).to_i
      end

      def self.decode(int)
        EPOCH_START + int
      end
    end

    module TimestampMillis
      def self.encode(value)
        time = value.to_time
        time.to_i * 1000 + time.usec / 1000
      end

      def self.decode(int)
        s, ms = int / 1000, int % 1000
        Time.at(s, ms * 1000).utc
      end
    end

    module TimestampMicros
      def self.encode(value)
        time = value.to_time
        time.to_i * 1000_000 + time.usec
      end

      def self.decode(int)
        s, us = int / 1000_000, int % 1000_000
        Time.at(s, us).utc
      end
    end

    module Identity
      def self.encode(datum)
        datum
      end

      def self.decode(datum)
        datum
      end
    end

    TYPES = {
      "int" => {
        "date" => IntDate
      },
      "long" => {
        "timestamp-millis" => TimestampMillis,
        "timestamp-micros" => TimestampMicros
      },
    }.freeze

    def self.type_adapter(type, logical_type)
      return unless logical_type

      TYPES.fetch(type, {}).fetch(logical_type, Identity)
    end
  end
end
