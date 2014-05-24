require 'spec_helper'

require 'roadie/route'
require 'roadie/match'

module Roadie
  describe Route do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:handler) { double('handler', call: ok_resp) }
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

        it 'sets params and returns the handler response' do
          expect(handler).to receive(:call).with('rack.routing_args' => url_params)
          expect(route.call(env)).to eq(ok_resp)
        end
      end

      context 'when the matcher doesn\'t match' do
        let(:matcher) { double(match: Match.fail) }

        it 'returns a 404 Not Found with X-Cascade => pass' do
          resp = route.call(env)
          expect(resp[0].to_i).to eq(404)
          expect(resp[1]['X-Cascade']).to eq('pass')
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
