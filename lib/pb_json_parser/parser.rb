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
            m.push_field(AST::Field.new(name: f["name"]))
          end
        else
          m.push_field(AST::Field.new(name: f["name"]))
        end
      end

      m
    end

    # @param [{ String => Any }] field
    # @return [AST::Association]
    def parse_assoc(field)
      case field["label"]
      when 3  # label: LABEL_REPEATED
        type = AST::Association::Type[:has_many]
      else
        type = AST::Association::Type[:has_one]
      end
      class_name = field_message_type(field)

      assoc = AST::Association.new(
        name:       field["name"],
        type:       type,
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
