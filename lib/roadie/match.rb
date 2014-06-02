module Roadie
  module Match
    def self.ok(params = {})
      Ok.new(params)
    end

    def self.fail
      Fail.new
    end

    class Ok
      attr_reader :params

      def initialize(params = {})
        @params = params
      end

      def ok?
        true
      end
    end

    class Fail
      def ok?
        false
      end

      def params
        {}
      end
    end
  end
end
