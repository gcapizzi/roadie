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

      def &(other)
        case other
        when Ok then Ok.new(@params.merge(other.params))
        else Fail.new
        end
      end
    end

    class Fail
      def ok?
        false
      end

      def params
        {}
      end

      def &(_)
        self
      end
    end
  end
end
