require 'mustermann'

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

    def url_for(route_name, params)
      @routes.find { |r| r.name == route_name }.expand_url(params)
    end

    def <<(route)
      @routes << route
    end

    def route(name, method, path, handler = Proc.new)
      self << Route.new(name, Matcher.new(path, methods: [method]), handler)
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
      match = @matcher.match(env)
      if match.ok?
        env[PARAMETERS_KEY] = match.params
        return @handler.call(env)
      end

      NOT_FOUND
    end

    def expand_url(params)
      @matcher.expand(params)
    end
  end

  class Matcher
    def initialize(path_pattern, methods: ['GET'])
      @methods = methods
      @path_pattern = path_pattern
    end

    def match(env)
      if matches?(env)
        SuccessfulMatch.new(params(env))
      else
        FailedMatch.new
      end
    end

    def expand(params)
      get_expander.expand(params)
    end

    private

    def matches?(env)
      @methods.include?(env['REQUEST_METHOD']) && @path_pattern =~ env['PATH_INFO']
    end

    def params(env)
      @path_pattern.params(env['PATH_INFO'])
    end

    def get_expander
      Mustermann::Expander.new(@path_pattern, additional_values: :ignore)
    end
  end

  class Match
    attr_reader :params, :ok

    def initialize(ok = false, params = {})
      @ok = ok
      @params = params
    end

    alias :ok? :ok
  end

  class SuccessfulMatch < Match
    def initialize(params)
      super(true, params)
    end
  end

  class FailedMatch < Match; end
end
