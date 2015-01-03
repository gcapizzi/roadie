require 'spec_helper'
require 'rack/test'

require 'roadie'

RSpec.describe Roadie do
  include Rack::Test::Methods

  let(:app) do
    Roadie.build do
      on [get, path('/foo')], :foo, proc { [200, {}, ['foo']] }

      on [post, path('/bar/*')], :bar, proc { [200, {}, ['bar']] }

      on [put, path('/resource/:id')], :resource, lambda { |env|
        [200, {}, [env['rack.routing_args']['id']]]
      }
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
