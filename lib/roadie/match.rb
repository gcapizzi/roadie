module Roadie
  class Match
    attr_reader :params, :ok

    def initialize(ok = false, params = {})
      @ok = ok
      @params = params
    end

    alias :ok? :ok

    def self.ok(params = {})
      new(true, params)
    end

    def self.fail
      new
    end
  end
end
