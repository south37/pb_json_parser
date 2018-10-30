require 'json'

module PbJsonParser
  class Parser
    # @param [String] json
    # @param [String] filename
    # @param [Config] config
    def initialize(json:, filename:)
      @data       = read_data(json, filename)
      @config     = Config.new
      @package    = @data["package"]
    end

    # @return [<AST::Message>]
    def parse
      r = []
      @data["message_type"].each do |m_type|
        m = parse_message(m_type)
        r.push m
      end
      r
    end

    def configure(&block)
      yield @config
    end

  private

    # @param [{ String => Any }] message_type
    # @return [<AST::Message>]
    def parse_message(message_type)
      m = AST::Message.new(name: message_type["name"])

      message_type["field"].each do |f|
        # NOTE: skip field when configured
        next if @config.skip_fields.include?(f["name"])

        case f["type"]
        when 11  # type: TYPE_MESSAGE
          if is_assoc?(f)
            m.push_assoc(parse_assoc(f))
          else
            m.push_field(parse_field(f, type: f["type_name"]))
          end
        when 14  # type: TYPE_ENUM
          m.push_field(parse_field(f, type: f["type_name"]))
        else
          m.push_field(parse_field(f, type: to_type(f["type"])))
        end
      end

      m
    end

    # @param [{ String => Any }] field
    # @return [AST::Association]
    def parse_assoc(field)
      case field["label"]
      when 3  # label: LABEL_REPEATED
        kind = AST::Association::Kind[:has_many]
      else
        kind = AST::Association::Kind[:has_one]
      end
      class_name = field_message_type(field)

      assoc = AST::Association.new(
        name:       field["name"],
        kind:       kind,
        class_name: class_name,
      )
    end

    # @param [{ string => Any }] field
    # @return [bool]
    def is_assoc?(field)
      field_package(field) == @package
    end

    # @param [Hash] field
    def field_package(field)
      # NOTE: field["type_name"] is `.<package>.<message_type>`.
      field["type_name"][1..@package.size]
    end

    # @param [Hash] field
    def field_message_type(field)
      # NOTE: field["type_name"] is `.<package>.<message_type>`.
      field["type_name"][(@package.size + 2)..-1]
    end

    # @param [{ String => Any }] field
    # @param [String] type
    # @return [AST::Field]
    def parse_field(field, type:)
      AST::Field.new(name: field["name"], type: type)
    end

    # @param [Integer] type
    # @return [String]
    def to_type(type)
      case type
      when 1
        'double'
      when 2
        'float'
      when 3
        'int64'
      when 4
        'uint64'
      when 5
        'int32'
      when 8
        'bool'
      when 9
        'string'
      when 12
        'bytes'
      when 13
        'uint32'
      when 17
        'sint32'
      when 18
        'sint64'
      else
        # TODO(south37) Handle other scalar value types
        # cf. https://developers.google.com/protocol-buffers/docs/proto#scalar
        "type[#{type}]"
      end
    end

    # @param [String] json
    # @return [Hash]
    def read_data(json, filename)
      h = JSON.parse(json)
      data = h["proto_file"].find { |f| f["name"] == filename }
      if !data
        raise "'#{filename}' does not exist in the json!"
      end
      data
    end
  end
end
