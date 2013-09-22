module Roadie
  NOT_FOUND = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  class Router
    def initialize(&block)
      @routes = []
      instance_eval(&block) if block
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

    def route(name, verb, path, handler = Proc.new)
      self << Route.new(name, Matcher.new(verb, path), handler)
    end

    def get    name, path, handler = Proc.new; route name, 'GET',    path, handler; end
    def post   name, path, handler = Proc.new; route name, 'POST',   path, handler; end
    def put    name, path, handler = Proc.new; route name, 'PUT',    path, handler; end
    def delete name, path, handler = Proc.new; route name, 'DELETE', path, handler; end

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
    def initialize(verb, path_pattern)
      @verb = String(verb)
      @path_pattern = path_pattern
    end

    def matches?(env)
      @verb == env['REQUEST_METHOD'] && @path_pattern =~ env['PATH_INFO']
    end
    alias :match :matches?

    def params(env)
      match = @path_pattern.match(env['PATH_INFO'])
      Hash[match.names.zip(match.captures)]
    end
  end
end
