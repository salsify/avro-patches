Avro::IO::DatumWriter.class_eval do
  def write_data(writers_schema, datum, encoder)
    unless Avro::Schema.validate(writers_schema, datum, recursive: false)
      raise Avro::IO::AvroTypeError.new(writers_schema, datum)
    end

    # function dispatch to write datum
    case writers_schema.type_sym
    when :null;    encoder.write_null(datum)
    when :boolean; encoder.write_boolean(datum)
    when :string;  encoder.write_string(datum)
    when :int;     encoder.write_int(datum)
    when :long;    encoder.write_long(datum)
    when :float;   encoder.write_float(datum)
    when :double;  encoder.write_double(datum)
    when :bytes;   encoder.write_bytes(datum)
    when :fixed;   write_fixed(writers_schema, datum, encoder)
    when :enum;    write_enum(writers_schema, datum, encoder)
    when :array;   write_array(writers_schema, datum, encoder)
    when :map;     write_map(writers_schema, datum, encoder)
    when :union;   write_union(writers_schema, datum, encoder)
    when :record, :error, :request;  write_record(writers_schema, datum, encoder)
    else
      raise Avro::AvroError.new("Unknown type: #{writers_schema.type}")
    end
  end
end

module AvroPatches
  module SchemaValidator
    module IOPatches
      def write_record(writers_schema, datum, encoder)
        raise Avro::IO::AvroTypeError.new(writers_schema, datum) unless datum.is_a?(Hash)
        super
      end

      def write_array(writers_schema, datum, encoder)
        raise Avro::IO::AvroTypeError.new(writers_schema, datum) unless datum.is_a?(Array)
        super
      end

      def write_map(writers_schema, datum, encoder)
        raise Avro::IO::AvroTypeError.new(writers_schema, datum) unless datum.is_a?(Hash)
        super
      end
    end
  end
end

Avro::IO::DatumWriter.prepend(AvroPatches::SchemaValidator::IOPatches)
