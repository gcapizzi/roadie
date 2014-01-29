require 'roadie/route'

module Roadie
  class Router
    def initialize(routes = [], default_route = proc { NOT_FOUND }, &block)
      @routes = routes
      @default_route = default_route
      instance_eval(&block) if block
    end

    def call(env)
      @routes.each do |route|
        resp = route.call(env)
        return resp unless pass?(resp)
      end

      @default_route.call(env)
    end

    def url_for(route_name, params = {})
      @routes.find { |r| r.name == route_name }.expand_url(params)
    end

    def <<(route)
      @routes << route
    end

    def route(name, path, handler = Proc.new, methods: ['GET'])
      self << Route.new(name, Matcher.new(path, methods: methods), handler)
    end

    def get     (name, path, handler = Proc.new) route name, path, handler                       end
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
end
