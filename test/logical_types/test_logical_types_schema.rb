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
end
