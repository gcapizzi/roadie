require 'mustermann'

require 'roadie/match'

module Roadie
  class Matcher
    attr_reader :path_pattern, :methods

    def initialize(path_pattern, methods: ['GET'])
      @path_pattern = Mustermann.new(path_pattern)
      @methods = methods
    end

    def match(env)
      if matches?(env)
        Match.ok(params(env))
      else
        Match.fail
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
