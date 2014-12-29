require 'spec_helper'
require 'rack/test'

require 'roadie/builder'

module Roadie
  RSpec.describe Builder do
    methods = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    describe '.build' do
      let(:app) do
        subject.build do
          methods.each do |method|
            send(method.downcase, :foo, '/foo', proc { [200, {}, [method]] })
          end
        end
      end

      it 'builds a Roadie app' do
        methods.each do |method|
          response = app.call(req(method, '/foo'))
          expect(response[2].first).to eq(method)
        end
        expect(app.call(req('GET', '/bar'))[0]).to eq(404)
      end
    end
  end
end
