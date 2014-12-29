require 'roadie/route'
require 'roadie/matcher'

module Roadie
  class Builder
    def initialize
      @routes = []
    end

    def build(&block)
      instance_eval(&block)
      build_route
    end

    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    methods.each do |method|
      method_name = method.downcase

      define_method(method_name) do |name, path, handler = nil, &block|
        matcher = Matcher.new(path, [method])
        route = Route.new(name, matcher, handler || block, nil)
        @routes.unshift(route)
      end
    end

    private

    def build_route
      @routes.reduce(PassRoute.new) { |app, route| route << app }
    end
  end
end
