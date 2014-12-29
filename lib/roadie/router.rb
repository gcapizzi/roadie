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
        response = route.call(env)
        return response unless pass?(response)
      end

      @default_route.call(env)
    end

    def expand_url(route_name, params = {})
      @routes.each do |route|
        expanded_url = route.expand_url(route_name, params)
        return expanded_url unless expanded_url.nil?
      end

      nil
    end

    private

    def pass?(response)
      response[1].key?('X-Cascade')
    end
  end
end
