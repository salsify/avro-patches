Avro::Schema.class_eval do
  def read?(writers_schema)
    Avro::SchemaCompatibility.can_read?(writers_schema, self)
  end

  def be_read?(other_schema)
    other_schema.read?(self)
  end

  def mutual_read?(other_schema)
    Avro::SchemaCompatibility.mutual_read?(other_schema, self)
  end
end

Avro::Schema::RecordSchema.class_eval do
  def initialize(name, namespace, fields, names=nil, schema_type=:record)
    if schema_type == :request || schema_type == 'request'
      @type_sym = schema_type.to_sym
      @namespace = namespace
    else
      super(schema_type, name, namespace, names)
    end
    @fields = if fields
                self.class.make_field_objects(fields, names, self.namespace)
              else
                {}
              end
  end
end

Avro::Schema::UnionSchema.class_eval do
  def initialize(schemas, names=nil, default_namespace=nil)
    super(:union)

    @schemas = schemas.each_with_object([]) do |schema, schema_objects|
      new_schema = subparse(schema, names, default_namespace)
      ns_type = new_schema.type_sym

      if Avro::Schema::VALID_TYPES_SYM.include?(ns_type) &&
        !Avro::Schema::NAMED_TYPES_SYM.include?(ns_type) &&
        schema_objects.any?{|o| o.type_sym == ns_type }
        raise Avro::SchemaParseError, "#{ns_type} is already in Union"
      elsif ns_type == :union
        raise Avro::SchemaParseError, "Unions cannot contain other unions"
      else
        schema_objects << new_schema
      end
    end
  end
end


module AvroPatches
  module SchemaCompatibility
    module FieldPatch
      def default?
        @default != :no_default
      end

      def to_avro(names = Set.new)
        super.tap do |avro|
          avro['default'] = default if default?
        end
      end
    end
  end
end

Avro::Schema::Field.prepend(AvroPatches::SchemaCompatibility::FieldPatch)
