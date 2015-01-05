require 'roadie/route'
require 'roadie/composite_matcher'

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
      define_method(method.downcase) do |name, path, handler = nil, &block|
        verb_matcher = VerbMatcher.new(method)
        path_matcher = PathMatcher.new(path)
        matcher = CompositeMatcher.new([verb_matcher, path_matcher])
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
