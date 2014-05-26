require 'spec_helper'

require 'roadie/route'
require 'roadie/match'

module Roadie
  RSpec.describe Route do
    let(:handler) { double(:handler) }
    let(:matcher) { double }
    let(:route) { Route.new(:foo, matcher, handler) }
    let(:env) { {} }

    it 'has a name' do
      expect(route.name).to eq(:foo)
    end

    describe '#call' do
      context 'when the matcher matches' do
        let(:url_params) { { 'foo' => 'bar' } }
        let(:matcher) { double(match: Match.ok(url_params)) }
        let(:handler_env) { { 'rack.routing_args' => url_params } }
        let(:ok_response) { [200, {}, ['ok']] }

        it 'sets params and returns the handler response' do
          expect(handler).to receive(:call).with(handler_env) { ok_response }
          expect(route.call(env)).to eq(ok_response)
        end
      end

      context 'when the matcher doesn\'t match' do
        let(:matcher) { double(match: Match.fail) }

        it 'returns a 404 Not Found with X-Cascade => pass' do
          response = route.call(env)
          expect(response[0].to_i).to eq(404)
          expect(response[1]['X-Cascade']).to eq('pass')
        end
      end
    end

    describe '#expand_url' do
      before do
        allow(matcher).to receive(:expand).with({}) { '/foo' }
        allow(matcher).to receive(:expand).with(id: '123') { '/foo/123' }
      end

      it 'expands the route URL' do
        expect(route.expand_url).to eq('/foo')
        expect(route.expand_url(id: '123')).to eq('/foo/123')
      end
    end
  end
end
