require 'spec_helper'

require 'roadie/route'
require 'roadie/matcher'

module Roadie
  RSpec.describe Route do
    let(:handler) { double(:handler) }
    let(:matcher) { instance_double(Matcher) }

    subject { Route.new('foo', matcher, handler) }

    it 'has a name' do
      expect(subject.name).to eq('foo')
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

        context 'when it has a next route' do
          let(:next_route) { instance_double(Route) }
          let(:next_response) { [200, {}, 'next'] }

          subject { Route.new('foo', matcher, handler, next_route) }

          before { expect(next_route).to receive(:call).with(env) { next_response } }

          it 'delegates to it' do
            response = subject.call(env)

            expect(response).to eq(next_response)
          end
        end
      end
    end

    describe '#expand_url' do
      context 'when called with the right name' do
        context 'and no params' do
          before { allow(matcher).to receive(:expand).with({}) { '/foo' } }

          it 'expands the route URL' do
            expect(subject.expand_url('foo')).to eq('/foo')
          end
        end

        context 'and a params hash' do
          before { allow(matcher).to receive(:expand).with(id: '123') { '/foo/123' } }

          it 'expands the route URL with the provided params' do
            expect(subject.expand_url('foo', id: '123')).to eq('/foo/123')
          end
        end
      end

      context 'when called with the wrong name' do
        it 'returns nil' do
          expect(subject.expand_url('bar', id: '123')).to be(nil)
        end

        context 'when it has a next route' do
          let(:next_route) { instance_double(Route) }

          subject { Route.new('foo', matcher, handler, next_route) }

          before { allow(next_route).to receive(:expand_url).with('bar', {}) { '/bar' } }

          it 'delegates to it' do
            expect(subject.expand_url('bar')).to eq('/bar')
          end
        end
      end
    end

    describe '#<<' do
      let(:next_route) { instance_double(Route) }

      it 'sets the next route' do
        subject << next_route

        expect(subject.next_route).to eq(next_route)
      end
    end
  end
end
