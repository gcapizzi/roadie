module Roadie
  NotFound = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  class Router
    def initialize(*routes)
      @routes = routes.flatten
    end

    def call(env)
      routes.each do |route|
        resp = route.call(env)
        return resp unless pass?(resp)
      end

      NotFound
    end

    def <<(route)
      @routes << route
    end

    def routes
      @routes + [default_route]
    end

    private

    def default_route
      lambda { |env| NotFound }
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
        params = @matcher.params(env)
        env[PARAMETERS_KEY] = params
        return @handler.call(env, params)
      end

      NotFound
    end
  end

  class Matcher
    def initialize(verb, path)
      @verb = Regexp.new(verb)
      @path = Regexp.new(path)
    end

    def matches?(env)
      @verb =~ env['REQUEST_METHOD'] && @path =~ env['PATH_INFO']
    end

    def params(env)
      verb_params = extract_params(@verb, env['REQUEST_METHOD'])
      path_params = extract_params(@path, env['PATH_INFO'])
      verb_params.merge(path_params)
    end

    private

    def extract_params(regex, string)
      match = regex.match(string)
      Hash[match.names.zip(match.captures)]
    end
  end
end
