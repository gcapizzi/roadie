module Roadie
  NOT_FOUND = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  class Route
    attr_reader :name

    PARAMETERS_KEY = 'rack.routing_args'

    def initialize(name, matcher, handler)
      @name = name
      @matcher = matcher
      @handler = handler
    end

    def call(env)
      match = @matcher.match(env)
      if match.ok?
        env[PARAMETERS_KEY] = match.params
        env['SCRIPT_NAME'] += env['PATH_INFO']
        env['PATH_INFO'] = ''
        return @handler.call(env)
      end

      NOT_FOUND
    end

    def expand_url(params = {})
      @matcher.expand(params)
    end
  end
end
