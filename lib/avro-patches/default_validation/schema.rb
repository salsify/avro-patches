module AvroPatches
  module DefaultValidation
    module FieldPatch
      def initialize(type, name, default=:no_default, order=nil, names=nil, namespace=nil)
        super

        validate_default! if default?
      end

      private

      def validate_default!
        type_for_default = if type.type_sym == :union
                             type.schemas.first
                           else
                             type
                           end

        Avro::SchemaValidator.validate!(type_for_default, default)
      rescue Avro::SchemaValidator::ValidationError => e
        raise Avro::SchemaParseError, "Error validating default for #{name}: #{e.message}"
      end
    end
  end
end

Avro::Schema::Field.prepend(AvroPatches::DefaultValidation::FieldPatch)
