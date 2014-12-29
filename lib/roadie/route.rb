require 'roadie/pass_route'

module Roadie
  class Route
    attr_reader :name, :next_route

    PARAMETERS_KEY = 'rack.routing_args'

    def initialize(name, matcher, handler, next_route)
      @name = name
      @matcher = matcher
      @handler = handler
      @next_route = next_route
    end

    def call(env)
      match = @matcher.match(env)
      if match.ok?
        @handler.call(PARAMETERS_KEY => match.params,
                      'SCRIPT_NAME' => env['SCRIPT_NAME'] + env['PATH_INFO'],
                      'PATH_INFO' => '')
      else
        @next_route.call(env)
      end
    end

    def expand_url(name, params = {})
      if name.eql?(@name)
        @matcher.expand(params)
      else
        @next_route.expand_url(name, params)
      end
    end

    def <<(next_route)
      @next_route = next_route
      self
    end
  end
end
