module PbJsonParser
  module AST
    class Association
      Type = {
        has_one:  "has_one".freeze,
        has_many: "has_many".freeze,
      }.freeze

      attr_reader :name, :type, :class_name

      # @param [String] name
      # @param [String] type
      # @param [String] class_name
      def initialize(name:, type:, class_name:)
        @name       = name
        @type       = type
        @class_name = class_name
        validate!
      end

      def to_h
        {
          name:       @name,
          type:       @type,
          class_name: @class_name,
        }
      end

    private

      def validate!
        if !Type.values.include?(@type)
          raise "Invalid type: #{@type}"
        end
      end
    end
  end
end
