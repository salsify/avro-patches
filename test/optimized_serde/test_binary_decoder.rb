require 'test_help'

class TestBinaryDecoder < Test::Unit::TestCase

  def decode(value, method)
    string_io = StringIO.new(value)
    decoder = Avro::IO::BinaryDecoder.new(string_io)
    decoder.send(method)
  end

  def encode(value, method)
    string_io = StringIO.new('', 'w')
    encoder = Avro::IO::BinaryEncoder.new(string_io)
    encoder.send(method, value)
    string_io.string
  end

  def check_encode_decode(value, type)
    decode_method = "read_#{type}"
    encode_method = "write_#{type}"
    encoded = encode(value, encode_method)
    decoded = decode(encoded, decode_method)
    assert_equal(value, decoded)
  end

  def test_byte!
    assert_equal([decode('x', :byte!)].pack('c'), 'x')
  end

  def test_float
    check_encode_decode(3.0, :float)
  end

  def test_double
    check_encode_decode(1.23456789, :double)
  end

  def test_string
    check_encode_decode('hello world', :string)
  end
end
