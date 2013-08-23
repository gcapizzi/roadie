require 'spec_helper'
require 'rack/test'

require './lib/roadie'

module Roadie
  describe Router do
    include Rack::Test::Methods

    let(:app) do
      router = Router.new
      router << Route.new(:foo, Matcher.new('GET', '/foo'), ->(env) { [200, {}, ['foo']] })
      router << Route.new(:woot, Matcher.new('POST', %r{/w(o+)t}), ->(env) { [200, {}, ['woot']] })

      router << Route.new(:resource, Matcher.new('PUT', %r{/resource/(?<id>.+)/?}), ->(env) {
        [200, {}, [env['rack.routing_args']['id']]]
      })

      router
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

    it 'matches an url with a regex' do
      post '/woooooot'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('woot')
    end

    it 'stores named matches in roadie.params' do
      put '/resource/123'
      expect(last_response.body).to eq('123')
    end
  end
end
