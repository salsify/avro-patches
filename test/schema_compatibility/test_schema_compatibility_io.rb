require 'test_help'

class TestSchemaCompatibilityIO < Test::Unit::TestCase
  def test_interchangeable_schemas
    interchangeable_schemas = ['"string"', '"bytes"']
    incorrect = 0
    interchangeable_schemas.each_with_index do |ws, i|
      writers_schema = Avro::Schema.parse(ws)
      datum_to_write = 'foo'
      readers_schema = Avro::Schema.parse(interchangeable_schemas[i == 0 ? 1 : 0])
      writer, * = write_datum(datum_to_write, writers_schema)
      datum_read = read_datum(writer, writers_schema, readers_schema)
      if datum_read != datum_to_write
        incorrect += 1
      end
    end
    assert_equal(incorrect, 0)
  end

  def test_array_schema_promotion
    writers_schema = Avro::Schema.parse('{"type":"array", "items":"int"}')
    readers_schema = Avro::Schema.parse('{"type":"array", "items":"long"}')
    datum_to_write = [1, 2]
    writer, * = write_datum(datum_to_write, writers_schema)
    datum_read = read_datum(writer, writers_schema, readers_schema)
    assert_equal(datum_read, datum_to_write)
  end

  def test_map_schema_promotion
    writers_schema = Avro::Schema.parse('{"type":"map", "values":"int"}')
    readers_schema = Avro::Schema.parse('{"type":"map", "values":"long"}')
    datum_to_write = { 'foo' => 1, 'bar' => 2 }
    writer, * = write_datum(datum_to_write, writers_schema)
    datum_read = read_datum(writer, writers_schema, readers_schema)
    assert_equal(datum_read, datum_to_write)
  end

  # copied helpers

  def write_datum(datum, writers_schema)
    writer = StringIO.new
    encoder = Avro::IO::BinaryEncoder.new(writer)
    datum_writer = Avro::IO::DatumWriter.new(writers_schema)
    datum_writer.write(datum, encoder)
    [writer, encoder, datum_writer]
  end

  def read_datum(buffer, writers_schema, readers_schema=nil)
    reader = StringIO.new(buffer.string)
    decoder = Avro::IO::BinaryDecoder.new(reader)
    datum_reader = Avro::IO::DatumReader.new(writers_schema, readers_schema)
    datum_reader.read(decoder)
  end
end
