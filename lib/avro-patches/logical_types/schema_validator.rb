module AvroPatches
  module LogicalTypes
    module SchemaValidatorPatch
      def validate!(expected_schema, logical_datum, options = { recursive: true, encoded: false, fail_on_extra_fields: false})
        options ||= {}
        options[:recursive] = true unless options.key?(:recursive)

        result = Avro::SchemaValidator::Result.new
        if options[:recursive]
          validate_recursive(expected_schema, logical_datum,
                             Avro::SchemaValidator::ROOT_IDENTIFIER, result, options)
        else
          validate_simple(expected_schema, logical_datum,
                          Avro::SchemaValidator::ROOT_IDENTIFIER, result, options)
        end
        fail Avro::SchemaValidator::ValidationError, result if result.failure?
        result
      end

      private

      def validate_recursive(expected_schema, logical_datum, path, result, options = {})
        datum = resolve_datum(expected_schema, logical_datum, options[:encoded])

        # The entire method is overridden so that encoded: true can be passed here
        validate_simple(expected_schema, datum, path, result, encoded: true)

        case expected_schema.type_sym
        when :array
          validate_array(expected_schema, datum, path, result, options)
        when :map
          validate_map(expected_schema, datum, path, result, options)
        when :union
          validate_union(expected_schema, datum, path, result, options)
        when :record, :error, :request
          fail Avro::SchemaValidator::TypeMismatchError unless datum.is_a?(Hash)
          expected_schema.fields.each do |field|
            deeper_path = deeper_path_for_hash(field.name, path)
            validate_recursive(field.type, datum[field.name], deeper_path, result, options)
          end
          if options[:fail_on_extra_fields]
            datum_fields = datum.keys.map(&:to_s)
            schema_fields = expected_schema.fields.map(&:name)
            (datum_fields - schema_fields).each do |extra_field|
              result.add_error(path, "extra field '#{extra_field}' - not in schema")
            end
          end
        end
      rescue Avro::SchemaValidator::TypeMismatchError
        result.add_error(path, "expected type #{expected_schema.type_sym}, got #{actual_value_message(datum)}")
      end

      def validate_simple(expected_schema, logical_datum, path, result, options = {})
        datum = resolve_datum(expected_schema, logical_datum, options[:encoded])
        super(expected_schema, datum, path, result)
      end

      def resolve_datum(expected_schema, logical_datum, encoded)
        if encoded
          logical_datum
        else
          expected_schema.type_adapter.encode(logical_datum) rescue nil
        end
      end

      def validate_array(expected_schema, datum, path, result, options = {})
        fail Avro::SchemaValidator::TypeMismatchError unless datum.is_a?(Array)
        datum.each_with_index do |d, i|
          validate_recursive(expected_schema.items, d, path + "[#{i}]", result, options)
        end
      end

      def validate_map(expected_schema, datum, path, result, options = {})
        fail Avro::SchemaValidator::TypeMismatchError unless datum.is_a?(Hash)
        datum.keys.each do |k|
          result.add_error(path, "unexpected key type '#{ruby_to_avro_type(k.class)}' in map") unless k.is_a?(String)
        end
        datum.each do |k, v|
          deeper_path = deeper_path_for_hash(k, path)
          validate_recursive(expected_schema.values, v, deeper_path, result, options)
        end
      end

      def validate_union(expected_schema, datum, path, result, options = {})
        if expected_schema.schemas.size == 1
          validate_recursive(expected_schema.schemas.first, datum, path, result, options)
          return
        end
        failures = []
        compatible_type = first_compatible_type(datum, expected_schema, path, failures)
        return unless compatible_type.nil?

        complex_type_failed = failures.detect { |r| Avro::SchemaValidator::COMPLEX_TYPES.include?(r[:type]) }
        if complex_type_failed
          complex_type_failed[:result].errors.each { |error| result << error }
        else
          types = expected_schema.schemas.map { |s| "'#{s.type_sym}'" }.join(', ')
          result.add_error(path, "expected union of [#{types}], got #{actual_value_message(datum)}")
        end
      end

    end
  end
end

Avro::SchemaValidator.singleton_class.prepend(AvroPatches::LogicalTypes::SchemaValidatorPatch)
