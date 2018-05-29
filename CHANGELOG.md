# avro-patches

## v0.3.4
- Allow promotion of nested records to optional 

## v0.3.3
- Restore basic validation of records, arrays, and maps before writing.
- Add validation to protect against nil value for map.

## v0.3.2
- Fix remaining Ruby 2.4 deprecation notices by replacing `require 'avro'`.

## v0.3.1
- Fix references to `Avro::SchemaParseError` and `Avro::UnknownSchemaError`.

## v0.3.0
- Further performance improvements for `Avro::SchemaValidator` and encoding.
- Ensure that strings are encoded as UTF-8.

## v0.2.0
- Performance improvements for `Avro::SchemaValidator`.

## v0.1.0
- Initial version
