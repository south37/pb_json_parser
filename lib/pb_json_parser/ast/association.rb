module PbJsonParser
  module AST
    class Association
      Kind = {
        has_one:  "has_one".freeze,
        has_many: "has_many".freeze,
      }.freeze

      attr_reader :name, :kind, :class_name

      # @param [String] name
      # @param [String] kind
      # @param [String] class_name
      def initialize(name:, kind:, class_name:)
        @name       = name
        @kind       = kind
        @class_name = class_name
        validate!
      end

      def to_h
        {
          name:       @name,
          kind:       @kind,
          class_name: @class_name,
        }
      end

    private

      def validate!
        if !Kind.values.include?(@kind)
          raise "Invalid kind: #{@kind}"
        end
      end
    end
  end
end
