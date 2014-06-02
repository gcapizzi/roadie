require 'spec_helper'
require 'rack/test'

require 'roadie/router'

module Roadie
  RSpec.describe Router do
    subject { Router.new(routes) }

    describe '.build' do
      it 'creates a router using a Builder' do
        router = Router.build do
          get :foo, '/foo', proc { [200, {}, 'FOO'] }
        end
        response = router.call(req('GET', '/foo'))
        expect(response.last).to eq('FOO')
      end
    end

    describe '#call' do
      let(:env) { {} }
      let(:ok_response) { [200, {}, ['ok']] }
      let(:pass_response) { [404, { 'X-Cascade' => 'pass' }, []] }
      let(:matching_route) { instance_double(Route) }
      let(:not_matching_route) { instance_double(Route) }
      let(:response) { subject.call(env) }

      before do
        allow(matching_route).to receive(:call).with(env) { ok_response }
        allow(not_matching_route).to receive(:call).with(env) { pass_response }
      end

      context 'when a route matches' do
        let(:other_matching_route) { instance_double(Route) }
        let(:routes) { [not_matching_route,
                        matching_route,
                        not_matching_route,
                        other_matching_route] }

        it 'stops trying and returns the route response' do
          expect(response).to eq(ok_response)
        end

        context 'when a matching route replies with X-Cascade => pass' do
          let(:ok_pass_response) { [200, { 'X-Cascade' => 'pass' }, []] }
          let(:passing_route) { instance_double(Route) }
          let(:routes) { [passing_route, matching_route] }

          before do
            allow(passing_route).to receive(:call).with(env) { ok_pass_response }
          end

          it 'keeps trying other routes' do
            expect(response).to eq(ok_response)
          end
        end
      end

      context 'when no route matches' do
        let(:routes) { [not_matching_route] * 3 }

        context 'when no default route is set' do
          it 'returns a 404 Not Found with X-Cascade => pass' do
            expect(response[0].to_i).to eq(404)
            expect(response[1]['X-Cascade']).to eq('pass')
          end
        end

        context 'when a default route is set' do
          let(:default_response) { [200, {}, ['default response']] }
          let(:default_route) { instance_double(Route) }

          before do
            allow(default_route).to receive(:call).with(env) { default_response }
          end

          subject { Router.new(routes, default_route) }

          it 'returns the response from the default route' do
            expect(subject.call(env)).to eq(default_response)
          end
        end
      end
    end

    describe '#url_for' do
      let(:route) { instance_double(Route, name: 'foo') }
      let(:routes) { [instance_double(Route, name: 'first'),
                      route,
                      instance_double(Route, name: 'last')] }

      context 'called without a params hash' do
        before { allow(route).to receive(:expand_url).with({}) { '/foo' } }

        it 'expands a route URL' do
          expect(subject.url_for('foo')).to eq('/foo')
        end
      end

      context 'called with a params hash' do
        before { allow(route).to receive(:expand_url).with(id: '123') { '/foo/123' } }

        it 'expands a route URL' do
          expect(subject.url_for('foo', id: '123')).to eq('/foo/123')
        end
      end
    end
  end
end
