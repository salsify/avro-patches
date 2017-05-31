module Avro
  module SchemaCompatibility
    def self.can_read?(writers_schema, readers_schema)
      Checker.new.can_read?(writers_schema, readers_schema)
    end

    def self.mutual_read?(writers_schema, readers_schema)
      Checker.new.mutual_read?(writers_schema, readers_schema)
    end

    def self.match_schemas(writers_schema, readers_schema)
      # Note: this does not support aliases!
      w_type = writers_schema.type_sym
      r_type = readers_schema.type_sym

      # This conditional is begging for some OO love.
      if w_type == :union || r_type == :union
        return true
      end

      if w_type == r_type
        return true if Avro::Schema::PRIMITIVE_TYPES_SYM.include?(r_type)

        case r_type
        when :record
          return writers_schema.fullname == readers_schema.fullname
        when :error
          return writers_schema.fullname == readers_schema.fullname
        when :request
          return true
        when :fixed
          return writers_schema.fullname == readers_schema.fullname &&
            writers_schema.size == readers_schema.size
        when :enum
          return writers_schema.fullname == readers_schema.fullname
        when :map
          return match_schemas(writers_schema.values, readers_schema.values)
        when :array
          return match_schemas(writers_schema.items, readers_schema.items)
        end
      end

      # Handle schema promotion
      if w_type == :int && [:long, :float, :double].include?(r_type)
        return true
      elsif w_type == :long && [:float, :double].include?(r_type)
        return true
      elsif w_type == :float && r_type == :double
        return true
      elsif w_type == :string && r_type == :bytes
        return true
      elsif w_type == :bytes && r_type == :string
        return true
      end

      return false
    end

    class Checker
      SIMPLE_CHECKS = Avro::Schema::PRIMITIVE_TYPES_SYM.dup.add(:fixed).freeze

      attr_reader :recursion_set
      private :recursion_set

      def initialize
        @recursion_set = Set.new
      end

      def can_read?(writers_schema, readers_schema)
        full_match_schemas(writers_schema, readers_schema)
      end

      def mutual_read?(writers_schema, readers_schema)
        can_read?(writers_schema, readers_schema) && can_read?(readers_schema, writers_schema)
      end

      private

      def full_match_schemas(writers_schema, readers_schema)
        return true if recursion_in_progress?(writers_schema, readers_schema)

        return false unless Avro::SchemaCompatibility.match_schemas(writers_schema, readers_schema)

        if writers_schema.type_sym != :union && SIMPLE_CHECKS.include?(readers_schema.type_sym)
          return true
        end

        case readers_schema.type_sym
        when :record
          match_record_schemas(writers_schema, readers_schema)
        when :map
          full_match_schemas(writers_schema.values, readers_schema.values)
        when :array
          full_match_schemas(writers_schema.items, readers_schema.items)
        when :union
          match_union_schemas(writers_schema, readers_schema)
        when :enum
          # reader's symbols must contain all writer's symbols
          (writers_schema.symbols - readers_schema.symbols).empty?
        else
          if writers_schema.type_sym == :union && writers_schema.schemas.size == 1
            full_match_schemas(writers_schema.schemas.first, readers_schema)
          else
            false
          end
        end
      end

      def match_union_schemas(writers_schema, readers_schema)
        raise 'readers_schema must be a union' unless readers_schema.type_sym == :union

        case writers_schema.type_sym
        when :union
          writers_schema.schemas.all? { |writer_type| full_match_schemas(writer_type, readers_schema) }
        else
          readers_schema.schemas.any? { |reader_type| full_match_schemas(writers_schema, reader_type) }
        end
      end

      def match_record_schemas(writers_schema, readers_schema)
        writer_fields_hash = writers_schema.fields_hash
        readers_schema.fields.each do |field|
          if writer_fields_hash.key?(field.name)
            return false unless full_match_schemas(writer_fields_hash[field.name].type, field.type)
          else
            return false unless field.default?
          end
        end

        return true
      end

      def recursion_in_progress?(writers_schema, readers_schema)
        key = [writers_schema.object_id, readers_schema.object_id]

        if recursion_set.include?(key)
          true
        else
          recursion_set.add(key)
          false
        end
      end
    end
  end
end
