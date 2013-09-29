require 'spec_helper'
require 'rack/test'

require './lib/roadie'

module Roadie
  describe Router do
    include Rack::Test::Methods

    let(:app) do
      Router.new do
        get :foo, Mustermann.new('/foo') do
          [200, {}, ['foo']]
        end

        post :bar, Mustermann.new('/bar/*')  do
          [200, {}, ['bar']]
        end

        put :resource, Mustermann.new('/resource/:id') do |env|
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

    describe '#url_for' do
      it 'expands the url for the given route' do
        expect(app.url_for(:foo)).to eq('/foo')
        expect(app.url_for(:resource, id: 123)).to eq('/resource/123')
      end
    end
  end
end
