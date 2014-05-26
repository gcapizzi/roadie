require 'roadie/route'
require 'roadie/builder'

module Roadie
  class Router
    def initialize(routes, default_route = proc { NOT_FOUND })
      @routes = routes
      @default_route = default_route
    end

    def self.build(&block)
      Builder.new.build(&block)
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

    private

    def pass?(response)
      response[1]['X-Cascade'] == 'pass'
    end
  end
end
