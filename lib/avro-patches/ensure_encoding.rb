# Change from "AVRO-1783: Ruby: Ensure correct binary encoding for byte strings"
# https://github.com/apache/avro/commit/315d842148d57590a58fafecf6e5ea378e9e0d74

# Only part of the above commit is included as we are not using protocols and RPC
require_relative 'ensure_encoding/io'
