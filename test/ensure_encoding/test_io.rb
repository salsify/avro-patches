require 'test_help'

class TestEnsureEncodingIO < Test::Unit::TestCase
  def test_utf8_string_encoding
    [
      "\xC3".force_encoding('ISO-8859-1'),
      "\xC3\x83".force_encoding('UTF-8')
    ].each do |value|
      output = ''.force_encoding('BINARY')
      encoder = Avro::IO::BinaryEncoder.new(StringIO.new(output))
      datum_writer = Avro::IO::DatumWriter.new(Avro::Schema.parse('"string"'))
      datum_writer.write(value, encoder)

      assert_equal "\x04\xc3\x83".force_encoding('BINARY'), output
    end
  end

  def test_bytes_encoding
    [
      "\xC3\x83".force_encoding('BINARY'),
      "\xC3\x83".force_encoding('ISO-8859-1'),
      "\xC3\x83".force_encoding('UTF-8')
    ].each do |value|
      output = ''.force_encoding('BINARY')
      encoder = Avro::IO::BinaryEncoder.new(StringIO.new(output))
      datum_writer = Avro::IO::DatumWriter.new(Avro::Schema.parse('"bytes"'))
      datum_writer.write(value, encoder)

      assert_equal "\x04\xc3\x83".force_encoding('BINARY'), output
    end
  end

  def test_fixed_encoding
    [
      "\xC3\x83".force_encoding('BINARY'),
      "\xC3\x83".force_encoding('ISO-8859-1'),
      "\xC3\x83".force_encoding('UTF-8')
    ].each do |value|
      output = ''.force_encoding('BINARY')
      encoder = Avro::IO::BinaryEncoder.new(StringIO.new(output))
      schema = '{"type": "fixed", "name": "TwoBytes", "size": 2}'
      datum_writer = Avro::IO::DatumWriter.new(Avro::Schema.parse(schema))
      datum_writer.write(value, encoder)

      assert_equal "\xc3\x83".force_encoding('BINARY'), output
    end
  end
end
