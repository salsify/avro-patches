Avro::IO::BinaryDecoder.class_eval do

  def byte!
    @reader.readbyte
  end

  def read_float
    read_and_unpack(4, 'e'.freeze)
  end

  def read_double
    read_and_unpack(8, 'E'.freeze)
  end

  def read_string
    read_bytes.tap do |string|
      string.force_encoding('utf-8'.freeze) if string.respond_to?(:force_encoding)
    end
  end

  private

  # Optimize unpacking strings when `unpack1` is available (ruby >= 2.4)
  if String.instance_methods.include?(:unpack1)

    def read_and_unpack(byte_count, format)
      @reader.read(byte_count).unpack1(format)
    end

  else

    def read_and_unpack(byte_count, format)
      @reader.read(byte_count).unpack(format)[0]
    end

  end
end

Avro::IO::BinaryEncoder.class_eval do

  def write_float(datum)
    @writer.write([datum].pack('e'.freeze))
  end

  def write_double(datum)
    @writer.write([datum].pack('E'.freeze))
  end

  def write_string(datum)
    datum = datum.encode('utf-8'.freeze) if datum.respond_to?(:encode)
    write_bytes(datum)
  end
end
