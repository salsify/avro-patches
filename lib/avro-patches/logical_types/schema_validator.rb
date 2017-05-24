module AvroPatches
  module LogicalTypes
    module SchemaValidatorPatch
      def validate!(expected_schema, logical_datum, encoded = false)
        result = Avro::SchemaValidator::Result.new
        validate_recursive(expected_schema, logical_datum, Avro::SchemaValidator::ROOT_IDENTIFIER, result, encoded)
        fail Avro::SchemaValidator::ValidationError, result if result.failure?
        result
      end

      private

      def validate_recursive(expected_schema, logical_datum, path, result, encoded = false)
        datum = if encoded
                  logical_datum
                else
                  expected_schema.type_adapter.encode(logical_datum) rescue nil
                end

        super(expected_schema, datum, path, result)
      end
    end
  end
end

Avro::SchemaValidator.singleton_class.prepend(AvroPatches::LogicalTypes::SchemaValidatorPatch)
