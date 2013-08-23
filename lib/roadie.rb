module Roadie
  NOT_FOUND = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  class Router
    def initialize(routes = [])
      @routes = routes
    end

    def call(env)
      @routes.each do |route|
        resp = route.call(env)
        return resp unless pass?(resp)
      end

      default_route.call(env)
    end

    def <<(route)
      @routes << route
    end

    private

    def default_route
      proc { NOT_FOUND }
    end

    def pass?(response)
      response[1]['X-Cascade'] == 'pass'
    end
  end

  class Route
    attr_reader :name

    PARAMETERS_KEY = 'rack.routing_args'

    def initialize(name, matcher, handler)
      @name = name
      @matcher = matcher
      @handler = handler
    end

    def call(env)
      if @matcher.matches?(env)
        env[PARAMETERS_KEY] = @matcher.params(env)
        return @handler.call(env)
      end

      NOT_FOUND
    end
  end

  class Matcher
    def initialize(verb, path)
      @verb = String(verb)
      @path = regex(path)
    end

    def matches?(env)
      @verb == env['REQUEST_METHOD'] && @path =~ env['PATH_INFO']
    end

    def params(env)
      extract_params(@path, env['PATH_INFO'])
    end

    private

    def regex(pattern)
      if pattern.is_a? String
        Regexp.compile("\\A#{Regexp.escape(pattern)}\\Z")
      else
        pattern
      end
    end

    def extract_params(regex, string)
      match = regex.match(string)
      Hash[match.names.zip(match.captures)]
    end
  end
end
