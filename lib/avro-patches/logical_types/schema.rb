Avro::Schema.class_eval do
  attr_reader :logical_type

  # Build Avro Schema from data parsed out of JSON string.
  def self.real_parse(json_obj, names=nil, default_namespace=nil)
    if json_obj.is_a? Hash
      type = json_obj['type']
      logical_type = json_obj['logicalType']
      raise Avro::SchemaParseError, %Q(No "type" property: #{json_obj}) if type.nil?

      # Check that the type is valid before calling #to_sym, since symbols are never garbage
      # collected (important to avoid DoS if we're accepting schemas from untrusted clients)
      unless Avro::Schema::VALID_TYPES.include?(type)
        raise Avro::SchemaParseError, "Unknown type: #{type}"
      end

      type_sym = type.to_sym
      if Avro::Schema::PRIMITIVE_TYPES_SYM.include?(type_sym)
        return Avro::Schema::PrimitiveSchema.new(type_sym, logical_type)

      elsif Avro::Schema::NAMED_TYPES_SYM.include? type_sym
        name = json_obj['name']
        namespace = json_obj.include?('namespace') ? json_obj['namespace'] : default_namespace
        case type_sym
        when :fixed
          size = json_obj['size']
          return Avro::Schema::FixedSchema.new(name, namespace, size, names, logical_type)
        when :enum
          symbols = json_obj['symbols']
          return Avro::Schema::EnumSchema.new(name, namespace, symbols, names)
        when :record, :error
          fields = json_obj['fields']
          return Avro::Schema::RecordSchema.new(name, namespace, fields, names, type_sym)
        else
          raise Avro::SchemaParseError.new("Unknown named type: #{type}")
        end

      else
        case type_sym
        when :array
          return Avro::Schema::ArraySchema.new(json_obj['items'], names, default_namespace)
        when :map
          return Avro::Schema::MapSchema.new(json_obj['values'], names, default_namespace)
        else
          raise Avro::SchemaParseError.new("Unknown Valid Type: #{type}")
        end
      end

    elsif json_obj.is_a? Array
      # JSON array (union)
      return Avro::Schema::UnionSchema.new(json_obj, names, default_namespace)
    elsif Avro::Schema::PRIMITIVE_TYPES.include? json_obj
      return Avro::Schema::PrimitiveSchema.new(json_obj)
    else
      raise Avro::Schema::UnknownSchemaError.new(json_obj)
    end
  end

  # Determine if a ruby datum is an instance of a schema
  def self.validate(expected_schema, logical_datum, options = { recursive: true, encoded: false })
    Avro::SchemaValidator.validate!(expected_schema, logical_datum, options)
    true
  rescue Avro::SchemaValidator::ValidationError
    false
  end

  def initialize(type, logical_type=nil)
    @type_sym = type.is_a?(Symbol) ? type : type.to_sym
    @logical_type = logical_type
  end

  def type_adapter
    @type_adapter ||= Avro::LogicalTypes.type_adapter(type, logical_type) || Avro::LogicalTypes::Identity
  end

  def to_avro(names=nil)
    props = {'type' => type}
    props['logicalType'] = logical_type if logical_type
    props
  end
end

Avro::Schema::NamedSchema.class_eval do
  def initialize(type, name, namespace=nil, names=nil, logical_type=nil)
    super(type, logical_type)
    @name, @namespace = Avro::Name.extract_namespace(name, namespace)
    Avro::Name.add_name(names, self)
  end
end

Avro::Schema::PrimitiveSchema.class_eval do
  def initialize(type, logical_type=nil)
    if Avro::Schema::PRIMITIVE_TYPES_SYM.include?(type)
      super(type, logical_type)
    elsif Avro::Schema::PRIMITIVE_TYPES.include?(type)
      super(type.to_sym, logical_type)
    else
      raise Avro::AvroError.new("#{type} is not a valid primitive type.")
    end
  end
end

Avro::Schema::FixedSchema.class_eval do
  def initialize(name, space, size, names=nil, logical_type=nil)
    # Ensure valid cto args
    unless size.is_a?(Integer)
      raise Avro::AvroError, 'Fixed Schema requires a valid integer for size property.'
    end
    super(:fixed, name, space, names, logical_type)
    @size = size
  end
end
