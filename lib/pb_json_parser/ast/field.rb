module PbJsonParser
  module AST
    class Field
      attr_reader :name

      # @param [String] name
      def initialize(name:)
        @name = name
      end
    end
  end
end
