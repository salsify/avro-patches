Avro::IO::DatumReader.class_eval do
  def self.match_schemas(writers_schema, readers_schema)
    Avro::SchemaCompatibility.match_schemas(writers_schema, readers_schema)
  end

  def read_record(writers_schema, readers_schema, decoder)
    readers_fields_hash = readers_schema.fields_hash
    read_record = {}
    writers_schema.fields.each do |field|
      if readers_field = readers_fields_hash[field.name]
        field_val = read_data(field.type, readers_field.type, decoder)
        read_record[field.name] = field_val
      else
        skip_data(field.type, decoder)
      end
    end

    # fill in the default values
    if readers_fields_hash.size > read_record.size
      writers_fields_hash = writers_schema.fields_hash
      readers_fields_hash.each do |field_name, field|
        unless writers_fields_hash.has_key? field_name
          if field.default?
            field_val = read_default_value(field.type, field.default)
            read_record[field.name] = field_val
          else
            raise Avro::AvroError, "Missing data for #{field.type} with no default"
          end
        end
      end
    end

    read_record
  end
end
