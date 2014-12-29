require 'roadie/pass_route'

module Roadie
  class Route
    attr_reader :name

    PARAMETERS_KEY = 'rack.routing_args'

    def initialize(name, matcher, handler, next_route = PassRoute.new)
      @name = name
      @matcher = matcher
      @handler = handler
      @next_route = next_route
    end

    def call(env)
      match = @matcher.match(env)
      if match.ok?
        env[PARAMETERS_KEY] = match.params
        env['SCRIPT_NAME'] += env['PATH_INFO']
        env['PATH_INFO'] = ''
        return @handler.call(env)
      end

      @next_route.call(env)
    end

    def expand_url(name, params = {})
      if name.eql?(@name)
        return @matcher.expand(params)
      end

      @next_route.expand_url(name, params)
    end
  end
end
