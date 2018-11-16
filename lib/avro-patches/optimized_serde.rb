Avro::IO::BinaryDecoder.class_eval do

  def byte!
    @reader.readbyte
  end

  def read_float
    @reader.read(4).unpack1('e'.freeze)
  end

  def read_double
    @reader.read(8).unpack1('E'.freeze)
  end
end

Avro::IO::BinaryEncoder.class_eval do

  def write_float(datum)
    @writer.write([datum].pack('e'.freeze))
  end

  def write_double(datum)
    @writer.write([datum].pack('E'.freeze))
  end
end
