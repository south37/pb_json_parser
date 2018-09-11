module PbJsonParser
  class Config
    attr_reader :skip_fields

    def initialize
      @skip_fields = []
    end

    # @param [<String>] fields
    def skip_fields=(fields)
      if !fields.is_a?(Array)
        raise "invalid skip_fields: #{fields}"
      end
      @skip_fields = fields
    end
  end
end
