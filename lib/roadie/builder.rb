require 'roadie/route'
require 'roadie/matcher'

module Roadie
  class Builder
    def initialize(routes = [])
      @routes = routes
    end

    def build(&block)
      instance_eval(&block)
      Router.new(@routes)
    end

    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    methods.each do |method|
      method_name = method.downcase

      define_method(method_name) do |name, path, handler = nil, &block|
        matcher = Matcher.new(path, methods: [method])
        handler ||= block
        @routes << Route.new(name, matcher, handler)
      end
    end
  end
end
