module Roadie
  class Match
    attr_reader :ok, :params

    def initialize(ok = false, params = {})
      @ok, @params = ok, params
    end

    alias_method :ok?, :ok

    def self.ok(params = {})
      new(true, params)
    end

    def self.fail
      new
    end
  end
end
