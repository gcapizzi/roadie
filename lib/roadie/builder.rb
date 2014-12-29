require 'roadie/route'
require 'roadie/matcher'

module Roadie
  class Builder
    def build(&block)
      instance_eval(&block)
      @root
    end

    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    methods.each do |method|
      method_name = method.downcase

      define_method(method_name) do |name, path, handler = nil, &block|
        matcher = Matcher.new(path, [method])
        route = Route.new(name, matcher, handler || block)

        @root ||= route
        @last_route << route if @last_route
        @last_route = route
      end
    end
  end
end
