require 'rack'

require 'roadie/builder'
require 'roadie/router'
require 'roadie/matcher'

module Roadie
  describe Builder do
    let(:router) { double(Router) }
    let(:route_name) { :route_name }
    let(:path) { '/foo' }

    subject { Builder.new(router) }

    methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS',
               'LINK', 'UNLINK']

    methods.each do |method|
      describe "##{method.downcase}" do
        before do
          expect(router).to receive(:<<) do |route|
            expect(route.name).to eq(route_name)
            response = Rack::MockRequest.new(route).request(method, path)
            expect(response.body).to eq("#{method} response")
          end
        end

        let(:method) { method }

        it "adds a #{method} route do the router" do
          method_name = method.downcase.to_sym
          handler = proc { [200, {}, "#{method} response"] }
          subject.send(method_name, route_name, path, handler)
        end
      end
    end
  end
end