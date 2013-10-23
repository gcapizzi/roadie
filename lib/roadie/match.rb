module Roadie
  class Match
    attr_reader :params, :ok

    def initialize(ok = false, params = {})
      @ok = ok
      @params = params
    end

    alias :ok? :ok
  end

  class SuccessfulMatch < Match
    def initialize(params)
      super(true, params)
    end
  end

  class FailedMatch < Match; end
end
