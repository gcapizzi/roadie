require 'roadie/match'

module Roadie
  class PathMatcher
    def initialize(pattern)
      @pattern = Mustermann.new(pattern)
    end

    def match(env)
      if @pattern =~ env['PATH_INFO']
        Match.ok(@pattern.params(env['PATH_INFO']))
      else
        Match.fail
      end
    end

    def expand(params = nil)
      @pattern.expand(params)
    end
  end
end
