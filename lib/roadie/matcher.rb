require 'mustermann'

require 'roadie/match'

module Roadie
  class Matcher
    def initialize(path_pattern, methods: ['GET'])
      @methods = methods
      @path_pattern = Mustermann.new(path_pattern)
    end

    def match(env)
      if matches?(env)
        SuccessfulMatch.new(params(env))
      else
        FailedMatch.new
      end
    end

    def expand(params = {})
      @path_pattern.expand(params)
    end

    private

    def matches?(env)
      @methods.include?(env['REQUEST_METHOD']) && @path_pattern =~ env['PATH_INFO']
    end

    def params(env)
      @path_pattern.params(env['PATH_INFO'])
    end
  end
end
