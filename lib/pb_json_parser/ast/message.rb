module PbJsonParser
  module AST
    class Message
      attr_reader :name, :fields, :assocs

      # @param [String] name
      def initialize(name:)
        @name   = name
        @fields = []
        @assocs = []
      end

      # @param [Field] f
      def push_field(f)
        @fields.push(f)
      end

      # @param [Association] a
      def push_assoc(a)
        @assocs.push(a)
      end

      def to_h
        {
          name:   @name,
          fields: @fields.map(&:to_h),
          assocs: @assocs.map(&:to_h),
        }
      end
    end
  end
end
