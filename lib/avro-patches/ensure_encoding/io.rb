Avro::IO::DatumWriter.class_eval do
  # A string is encoded as a long followed by that many bytes of
  # UTF-8 encoded character data
  def write_string(datum)
    # The original commit used:
    #   datum = datum.encode('utf-8') if datum.respond_to? :encode
    # This always allocated a new string even if the string was already UTF-8 encoded.
    # The form below is slightly more efficient.
    datum = datum.encode(Encoding::UTF_8) if datum.respond_to?(:encode) && datum.encoding != Encoding::UTF_8
    write_bytes(datum)
  end
end
