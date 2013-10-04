require 'mustermann'

module Roadie
  NOT_FOUND = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  class Router
    attr_accessor :default_route

    def initialize(default_route = proc { NOT_FOUND }, &block)
      @routes = []
      @default_route = default_route
      instance_eval(&block) if block
    end

    def call(env)
      @routes.each do |route|
        resp = route.call(env)
        return resp unless pass?(resp)
      end

      default_route.call(env)
    end

    def url_for(route_name, params = {})
      @routes.find { |r| r.name == route_name }.expand_url(params)
    end

    def <<(route)
      @routes << route
    end

    def route(name, path, handler = Proc.new, methods: [])
      self << Route.new(name, Matcher.new(Mustermann.new(path), methods: methods), handler)
    end

    def get     (name, path, handler = Proc.new) route name, path, handler, methods: ['GET']     end
    def post    (name, path, handler = Proc.new) route name, path, handler, methods: ['POST']    end
    def put     (name, path, handler = Proc.new) route name, path, handler, methods: ['PUT']     end
    def patch   (name, path, handler = Proc.new) route name, path, handler, methods: ['PATCH']   end
    def delete  (name, path, handler = Proc.new) route name, path, handler, methods: ['DELETE']  end
    def head    (name, path, handler = Proc.new) route name, path, handler, methods: ['HEAD']    end
    def options (name, path, handler = Proc.new) route name, path, handler, methods: ['OPTIONS'] end
    def link    (name, path, handler = Proc.new) route name, path, handler, methods: ['LINK']    end
    def unlink  (name, path, handler = Proc.new) route name, path, handler, methods: ['UNLINK']  end

    private

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

    def expand_url(params = {})
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
