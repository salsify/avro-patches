require 'test_help'

class TestSchemaCompatibilitySchema < Test::Unit::TestCase

  def test_empty_record
    schema = Avro::Schema.parse('{"type":"record", "name":"Empty"}')
    assert_empty(schema.fields)
  end

  def test_empty_union
    schema = Avro::Schema.parse('[]')
    assert_equal(schema.to_s, '[]')
  end

  def test_read
    schema = Avro::Schema.parse('"string"')
    writer_schema = Avro::Schema.parse('"int"')
    assert_false(schema.read?(writer_schema))
    assert_true(schema.read?(schema))
  end

  def test_be_read
    schema = Avro::Schema.parse('"string"')
    writer_schema = Avro::Schema.parse('"int"')
    assert_false(schema.be_read?(writer_schema))
    assert_true(schema.be_read?(schema))
  end

  def test_mutual_read
    schema = Avro::Schema.parse('"string"')
    writer_schema = Avro::Schema.parse('"int"')
    default1 = Avro::Schema.parse('{"type":"record", "name":"Default", "fields":[{"name":"i", "type":"int", "default": 1}]}')
    default2 = Avro::Schema.parse('{"type":"record", "name":"Default", "fields":[{"name:":"s", "type":"string", "default": ""}]}')
    assert_false(schema.mutual_read?(writer_schema))
    assert_true(schema.mutual_read?(schema))
    assert_true(default1.mutual_read?(default2))
  end

end
