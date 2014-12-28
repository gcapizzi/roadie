require 'spec_helper'

require 'roadie/route'
require 'roadie/matcher'

module Roadie
  RSpec.describe Route do
    let(:handler) { double(:handler) }
    let(:matcher) { instance_double(Matcher) }

    subject { Route.new(:foo, matcher, handler) }

    it 'has a name' do
      expect(subject.name).to eq(:foo)
    end

    describe '#call' do
      let(:env) { { 'PATH_INFO' => '/path/123', 'SCRIPT_NAME' => '/prefix' } }

      before { allow(matcher).to receive(:match).with(env) { match } }

      context 'when the matcher matches' do
        let(:url_params) { { 'foo' => 'bar' } }
        let(:match) { Match.ok(url_params) }
        let(:handler_response) { [200, {}, ['ok']] }

        it 'calls the handler and returns its response' do
          expect(handler).to receive(:call) do |env|
            expect(env).to include('rack.routing_args' => url_params)
            expect(env).to include('SCRIPT_NAME' => '/prefix/path/123')
            expect(env).to include('PATH_INFO' => '')

            handler_response
          end

          response = subject.call(env)

          expect(response).to eq(handler_response)
        end
      end

      context 'when the matcher doesn\'t match' do
        let(:match) { Match.fail }

        it 'returns a 404 Not Found with X-Cascade => pass' do
          response = subject.call(env)

          expect(response[0].to_i).to eq(404)
          expect(response[1]['X-Cascade']).to eq('pass')
        end
      end
    end

    describe '#expand_url' do
      context 'called without params' do
        before { allow(matcher).to receive(:expand).with({}) { '/foo' } }

        it 'expands the route URL' do
          expect(subject.expand_url).to eq('/foo')
        end
      end

      context 'called with a params hash' do
        before { allow(matcher).to receive(:expand).with(id: '123') { '/foo/123' } }

        it 'expands the route URL' do
          expect(subject.expand_url(id: '123')).to eq('/foo/123')
        end
      end
    end
  end
end
