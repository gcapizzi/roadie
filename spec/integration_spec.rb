require 'spec_helper'
require 'rack/test'

require 'roadie'

module Roadie
  RSpec.describe 'Integration spec' do
    include Rack::Test::Methods

    let(:app) do
      Router.build do
        get :foo, '/foo' do
          [200, {}, ['foo']]
        end

        post :bar, '/bar/*'  do
          [200, {}, ['bar']]
        end

        put :resource, '/resource/:id' do |env|
          [200, {}, [env['rack.routing_args']['id']]]
        end
      end
    end

    it 'returns 404 by default' do
      get '/'
      expect(last_response.status).to eq(404)
    end

    it 'matches a simple url' do
      get '/foo'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('foo')
    end

    it 'matches an url with a pattern' do
      post '/bar/bla/bla'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('bar')
    end

    it 'stores named matches in rack.routing_args' do
      put '/resource/123'
      expect(last_response.body).to eq('123')
    end

    describe '#expand_url' do
      it 'expands the url for the given route' do
        expect(app.expand_url(:foo)).to eq('/foo')
        expect(app.expand_url(:resource, id: 123)).to eq('/resource/123')
      end
    end
  end
end
