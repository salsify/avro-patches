require 'test_help'

class TestLogicalTypesIO < Test::Unit::TestCase
  DATAFILE = 'tmp/test.rb.avro'

  def test_record_with_logical_type
    record_schema = <<EOS
      {"type": "record",
       "name": "Test",
       "fields": [{"name": "ts",
                   "type": {"type": "long",
                            "logicalType": "timestamp-micros"}}]}
EOS
    check(record_schema)
  end

  def test_union
    union_schema = <<EOS
      ["string",
       {"type": "int", "logicalType": "date"},
       "null",
       "long",
       {"type": "record",
        "name": "Cons",
        "fields": [{"name": "car", "type": "string"},
                   {"name": "cdr", "type": "string"}]}]
EOS
    check(union_schema)
    check_default('["double", "long"]', "1.1", 1.1)
  end

  # copied helper methods

  def check(str)
    # parse schema, then convert back to string
    schema = Avro::Schema.parse str

    parsed_string = schema.to_s

    # test that the round-trip didn't mess up anything
    # NB: I don't think we should do this. Why enforce ordering?
    assert_equal(MultiJson.load(str),
                 MultiJson.load(parsed_string))

    # test __eq__
    assert_equal(schema, Avro::Schema.parse(str))

    # test hashcode doesn't generate infinite recursion
    schema.hash

    # test serialization of random data
    randomdata = RandomData.new(schema)
    9.times { checkser(schema, randomdata) }

    # test writing of data to file
    check_datafile(schema)

    # check that AvroError is raised when there is no default
    check_no_default(str)
  end

  def checkser(schm, randomdata)
    datum = randomdata.next
    assert validate(schm, datum), 'datum is not valid for schema'
    w = Avro::IO::DatumWriter.new(schm)
    writer = StringIO.new "", "w"
    w.write(datum, Avro::IO::BinaryEncoder.new(writer))
    r = datum_reader(schm)
    reader = StringIO.new(writer.string)
    ob = r.read(Avro::IO::BinaryDecoder.new(reader))
    assert_equal(datum, ob) # FIXME check on assertdata conditional
  end

  def check_datafile(schm)
    seed = 0
    count = 10
    random_data = RandomData.new(schm, seed)


    f = File.open(DATAFILE, 'wb')
    dw = Avro::DataFile::Writer.new(f, datum_writer(schm), schm)
    count.times{ dw << random_data.next }
    dw.close

    random_data = RandomData.new(schm, seed)


    f = File.open(DATAFILE, 'r+')
    dr = Avro::DataFile::Reader.new(f, datum_reader(schm))

    last_index = nil
    dr.each_with_index do |data, c|
      last_index = c
      # FIXME assertdata conditional
      assert_equal(random_data.next, data)
    end
    dr.close
    assert_equal count, last_index+1
  end

  def check_no_default(schema_json)
    actual_schema = '{"type": "record", "name": "Foo", "fields": []}'
    actual = Avro::Schema.parse(actual_schema)

    expected_schema = <<EOS
      {"type": "record",
       "name": "Foo",
       "fields": [{"name": "f", "type": #{schema_json}}]}
EOS
    expected = Avro::Schema.parse(expected_schema)

    reader = Avro::IO::DatumReader.new(actual, expected)
    assert_raise Avro::AvroError do
      value = reader.read(Avro::IO::BinaryDecoder.new(StringIO.new))
      assert_not_equal(value, :no_default) # should never return this
    end
  end

  def check_default(schema_json, default_json, default_value)
    actual_schema = '{"type": "record", "name": "Foo", "fields": []}'
    actual = Avro::Schema.parse(actual_schema)

    expected_schema = <<EOS
      {"type": "record",
       "name": "Foo",
       "fields": [{"name": "f", "type": #{schema_json}, "default": #{default_json}}]}
EOS
    expected = Avro::Schema.parse(expected_schema)

    reader = Avro::IO::DatumReader.new(actual, expected)
    record = reader.read(Avro::IO::BinaryDecoder.new(StringIO.new))
    assert_equal default_value, record["f"]
  end

  def validate(schm, datum)
    Avro::Schema.validate(schm, datum)
  end

  def datum_writer(schm)
    Avro::IO::DatumWriter.new(schm)
  end

  def datum_reader(schm)
    Avro::IO::DatumReader.new(schm)
  end
end
