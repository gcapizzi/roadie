require 'spec_helper'
require 'rack/test'

require './lib/roadie'

module Roadie
  describe Router do
    include Rack::Test::Methods

    let(:app) do
      router = Router.new
      router << Route.new(:foo, Matcher.new('GET', '/foo'), lambda { |env| [200, {}, ['foo']] })
      router << Route.new(:woot, Matcher.new('POST', %r{/w(o+)t}), lambda { |env| [200, {}, ['woot']] })
      router << Route.new(:p_verb, Matcher.new(/P(.+)/, '/p-verb'), lambda { |env| [200, {}, ['p-verb']] })

      router << Route.new(:resource, Matcher.new(/(?<verb>.+)/, %r{/resource/(?<id>.+)/?}), lambda { |env|
        [200, {}, ["ID: #{env['rack.routing_args']['id']}, Verb: #{env['rack.routing_args']['verb']}"]]
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

    it 'matches a verb with a regex' do
      post '/p-verb'
      expect(last_response.status).to eq(200)

      put '/p-verb'
      expect(last_response.status).to eq(200)

      patch '/p-verb'
      expect(last_response.status).to eq(200)

      get '/p-verb'
      expect(last_response.status).to eq(404)
    end

    it 'stores named matches in roadie.params' do
      put '/resource/123'
      expect(last_response.body).to eq('ID: 123, Verb: PUT')
    end
  end
end
