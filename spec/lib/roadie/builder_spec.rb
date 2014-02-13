require 'roadie/builder'
require 'roadie/router'
require 'roadie/matcher'

module Roadie
  describe Builder do
    let(:router) { double(Router) }
    let(:matcher) { double(Matcher) }
    let(:handler) { double(:handler) }
    let(:route) { double(Route, name: :foo, matcher: matcher, handler: handler) }
    let(:path) { '/foo' }

    before do
      allow(Route).to receive(:new).with(route.name, matcher, route.handler).and_return(route)
      allow(Matcher).to receive(:new).with(path, methods: [method]).and_return(matcher)

      expect(router).to receive(:<<).with(route)
    end

    subject { Builder.new(router) }

    methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS',
               'LINK', 'UNLINK']

    methods.each do |method|
      describe "##{method.downcase}" do
        let(:method) { method }

        it "adds a #{method} route do the router" do
          method_name = method.downcase.to_sym
          subject.send(method_name, route.name, path, handler)
        end
      end
    end
  end
end
