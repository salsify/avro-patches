require 'avro-patches/version'

# Calling require 'avro' leads to deprecation notices because requiring
# 'avro/ipc' calls methods that this gem patches.
#
# Replicate the require statements from avro.rb so that we can insert
# patches into the load order:

require 'multi_json'
require 'set'
require 'digest/md5'
require 'net/http'
require 'stringio'
require 'zlib'

module Avro
  class AvroError < StandardError; end

  class AvroTypeError < Avro::AvroError
    def initialize(schm=nil, datum=nil, msg=nil)
      msg ||= "Not a #{schm.to_s}: #{datum}"
      super(msg)
    end
  end
end

require 'avro/schema'
require 'avro/io'
require 'avro/schema_normalization'

# insert avro-patches
require 'avro-patches/ensure_encoding'
require 'avro-patches/schema_validator'
require 'avro-patches/logical_types'
require 'avro-patches/schema_compatibility'
require 'avro-patches/default_validation'
require 'avro-patches/optimized_serde'

# Remaining requires from the official avro gem
require 'avro/data_file'
require 'avro/protocol'
require 'avro/ipc'
