require 'roadie/route'
require 'roadie/matcher'

module Roadie
  class Builder
    def initialize(router)
      @router = router
    end

    def build(&block)
      instance_eval(&block)
      @router
    end

    methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS',
               'LINK', 'UNLINK']

    methods.each do |method|
      method_name = method.downcase

      define_method(method_name) do |name, path, handler = nil, &block|
        matcher = Matcher.new(path, methods: [method])
        handler ||= block
        @router << Route.new(name, matcher, handler)
      end
    end
  end
end
