require 'spec_helper'
require 'rack/test'

require 'roadie/builder'

module Roadie
  RSpec.describe Builder do
    verbs = %w(GET POST PUT PATCH DELETE HEAD OPTIONS LINK UNLINK)

    describe '.build' do
      let(:app) do
        subject.build do
          verbs.each do |v|
            on [verb(v), path('/foo')], v.downcase, proc { [200, {}, [v]] }
          end
        end
      end

      it 'builds a Roadie app' do
        verbs.each do |verb|
          response = app.call(req(verb, '/foo'))
          expect(response[2].first).to eq(verb)
        end
        expect(app.call(req('GET', '/bar'))[0]).to eq(404)
        expect(app.expand_url('patch')).to eq('/foo')
      end
    end
  end
end
