require 'test_help'

class TestLogicalTypesSchema < Test::Unit::TestCase
  def test_to_avro_includes_logical_type
    schema = Avro::Schema.parse <<-SCHEMA
      {"type": "record", "name": "has_logical", "fields": [
        {"name": "dt", "type": {"type": "int", "logicalType": "date"}}]
      }
    SCHEMA

    assert_equal schema.to_avro, {
      'type' => 'record', 'name' => 'has_logical',
      'fields' => [
        {'name' => 'dt', 'type' => {'type' => 'int', 'logicalType' => 'date'}}
      ]
    }
  end

  def test_real_parse_without_type
    json_obj = { 'foo' => 'bar' }
    assert_raise(Avro::SchemaParseError, "No \"type\" property: #{json_obj}") do
      Avro::Schema.real_parse(json_obj)
    end
  end

  def test_real_parse_with_unknown_type
    assert_raise(Avro::SchemaParseError, "Unknown type: foo") do
      Avro::Schema.real_parse('type' => 'foo')
    end
  end

  def test_real_parse_with_union_type
    assert_raise(Avro::SchemaParseError, "Unknown Valid Type: union") do
      Avro::Schema.real_parse('type' => 'union')
    end
  end

  def test_real_parse_with_request_type
    assert_raise(Avro::SchemaParseError, "Unknown Valid Type: request") do
      Avro::Schema.real_parse('type' => 'request')
    end
  end

  def test_real_parse_with_unknown_object
    object = Object.new
    assert_raise(Avro::UnknownSchemaError, "#{object} is not a schema we know about") do
      Avro::Schema.real_parse(object)
    end
  end
end
