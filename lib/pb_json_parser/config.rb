module PbJsonParser
  class Config
    attr_reader :skip_fields, :field_types

    def initialize
      @skip_fields = []
      @field_types = []
    end

    # @param [<String>] fields
    def skip_fields=(fields)
      if !fields.is_a?(Array)
        raise "invalid skip_fields: #{fields}"
      end
      @skip_fields = fields
    end

    # @param [<String>] types
    def field_types=(types)
      if !types.is_a?(Array)
        raise "invalid field_types: #{types}"
      end
      @field_types = types
    end
  end
end
