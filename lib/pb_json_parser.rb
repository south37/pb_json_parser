require "pb_json_parser/version"
require "pb_json_parser/ast"
require "pb_json_parser/config"
require "pb_json_parser/parser"

module PbJsonParser
  class << self
    # @param [String] json
    # @param [String] filename
    # @return [<AST::Message>]
    def parse(json:, filename:, skip_fields: [], field_types: [])
      parser = Parser.new(json: json, filename: filename)
      parser.configure do |c|
        c.skip_fields = skip_fields
        c.field_types = field_types
      end
      parser.parse
    end
  end
end
