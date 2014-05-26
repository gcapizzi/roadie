require 'rack/test'

require 'roadie/builder'
require 'roadie/router'
require 'roadie/matcher'

module Roadie
  RSpec.describe Builder do
    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    methods.each do |method|
      describe "##{method.downcase}" do
        let(:router) {
          subject.build do
            send(method.downcase, :foo, '/foo', proc { [200, {}, method] })
          end
        }

        it "adds a #{method} route do the router" do
          response = Rack::MockRequest.new(router).request(method, '/foo')
          expect(response.body).to eq(method)
        end
      end
    end
  end
end
