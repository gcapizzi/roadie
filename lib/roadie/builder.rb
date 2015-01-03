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

    def on(matchers, route_name, handler)
      matcher = CompositeMatcher.new(matchers)
      route = Route.new(route_name, matcher, handler, nil)
      @routes.unshift(route)
    end

    def verb(verb)
      VerbMatcher.new(verb)
    end

    def path(path)
      PathMatcher.new(path)
    end

    verbs = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)
    verbs.each { |v| define_method(v.downcase) { verb(v) } }

    private

    def build_route
      @routes.reduce(PassRoute.new) { |app, route| route << app }
    end
  end
end
