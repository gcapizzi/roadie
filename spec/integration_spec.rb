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

        post :woot, Mustermann.new('/woot/*')  do
          [200, {}, ['woot']]
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
      post '/woot/bla/bla'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('woot')
    end

    it 'stores named matches in rack.routing_args' do
      put '/resource/123'
      expect(last_response.body).to eq('123')
    end
  end
end
