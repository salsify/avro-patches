module AvroPatches
  module LogicalTypes
    module SchemaValidatorPatch
      def validate!(expected_schema, logical_datum, options = { recursive: true, encoded: false })
        options ||= {}
        options[:recursive] = true unless options.key?(:recursive)

        result = Avro::SchemaValidator::Result.new
        if options[:recursive]
          validate_recursive(expected_schema, logical_datum, Avro::SchemaValidator::ROOT_IDENTIFIER, result, options[:encoded])
        else
          validate_simple(expected_schema, logical_datum, Avro::SchemaValidator::ROOT_IDENTIFIER, result, options[:encoded])
        end
        fail Avro::SchemaValidator::ValidationError, result if result.failure?
        result
      end

      private

      def validate_recursive(expected_schema, logical_datum, path, result, encoded = false)
        datum = resolve_datum(expected_schema, logical_datum, encoded)

        # The entire method is overridden so that encoded: true can be passed here
        validate_simple(expected_schema, datum, path, result, true)

        case expected_schema.type_sym
        when :array
          validate_array(expected_schema, datum, path, result)
        when :map
          validate_map(expected_schema, datum, path, result)
        when :union
          validate_union(expected_schema, datum, path, result)
        when :record, :error, :request
          fail Avro::SchemaValidator::TypeMismatchError unless datum.is_a?(Hash)
          expected_schema.fields.each do |field|
            deeper_path = deeper_path_for_hash(field.name, path)
            validate_recursive(field.type, datum[field.name], deeper_path, result)
          end
        end
      rescue Avro::SchemaValidator::TypeMismatchError
        result.add_error(path, "expected type #{expected_schema.type_sym}, got #{actual_value_message(datum)}")
      end

      def validate_simple(expected_schema, logical_datum, path, result, encoded = false)
        datum = resolve_datum(expected_schema, logical_datum, encoded)
        super(expected_schema, datum, path, result)
      end

      def resolve_datum(expected_schema, logical_datum, encoded)
        if encoded
          logical_datum
        else
          expected_schema.type_adapter.encode(logical_datum) rescue nil
        end
      end
    end
  end
end

Avro::SchemaValidator.singleton_class.prepend(AvroPatches::LogicalTypes::SchemaValidatorPatch)
