require 'spec_helper'
require 'rack/test'

require 'roadie/builder'
require 'roadie/router'

module Roadie
  RSpec.describe Builder do
    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    methods.each do |method|
      describe "##{method.downcase}" do
        let(:router) do
          subject.build do
            send(method.downcase, :foo, '/foo', proc { [200, {}, method] })
          end
        end

        it "adds a #{method} route do the router" do
          response = router.call(req(method, '/foo'))
          expect(response[2]).to eq(method)
        end
      end
    end
  end
end
