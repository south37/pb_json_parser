module PbJsonParser
  module AST
    class Field
      attr_reader :name, :type

      # @param [String] name
      # @param [String] type
      def initialize(name:, type:)
        @name = name
        @type = type
      end

      def to_h
        {
          name: @name,
          type: @type,
        }
      end
    end
  end
end
