require 'test_help'

class TestSchemaValidatorIO < Test::Unit::TestCase
  def test_record_with_nil
    schema = Avro::Schema.parse('{"type":"record", "name":"rec", "fields":[{"type":"int", "name":"i"}]}')
    assert_raise(Avro::IO::AvroTypeError) do
      write_datum(nil, schema)
    end
  end

  def test_array_with_nil
    schema = Avro::Schema.parse('{"type":"array", "items":"int"}')
    assert_raise(Avro::IO::AvroTypeError) do
      write_datum(nil, schema)
    end
  end

  def test_map_with_nil
    schema = Avro::Schema.parse('{"type":"map", "values":"long"}')
    assert_raise(Avro::IO::AvroTypeError) do
      write_datum(nil, schema)
    end
  end

  # helper

  def write_datum(datum, writers_schema)
    writer = StringIO.new
    encoder = Avro::IO::BinaryEncoder.new(writer)
    datum_writer = Avro::IO::DatumWriter.new(writers_schema)
    datum_writer.write(datum, encoder)
    writer
  end
end
