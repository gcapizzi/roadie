require 'spec_helper'
require 'rack/test'

require 'roadie/router'

module Roadie
  RSpec.describe Router do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:matching_route) { instance_double(Route) }
    let(:pass_resp) { [404, { 'X-Cascade' => 'pass' }, []] }
    let(:not_matching_route) { instance_double(Route) }
    let(:env) { {} }

    subject { Router.new(routes) }

    before do
      allow(matching_route).to receive(:call).with(env) { ok_resp }
      allow(not_matching_route).to receive(:call).with(env) { pass_resp }
    end

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
      context 'when a route matches' do
        let(:other_matching_route) { instance_double(Route, call: ok_resp) }
        let(:routes) { [not_matching_route,
                        matching_route,
                        not_matching_route,
                        other_matching_route] }

        it 'stops trying and returns the route response' do
          expect(other_matching_route).not_to receive(:call)
          expect(subject.call(env)).to eq(ok_resp)
        end

        context 'when a matching route replies with X-Cascade => pass' do
          let(:ok_pass_resp) { [200, { 'X-Cascade' => 'pass' }, []] }
          let(:passing_route) { instance_double(Route) }
          let(:routes) { [passing_route, matching_route] }

          before { allow(passing_route).to receive(:call).with(env) { ok_pass_resp } }

          it 'keeps trying other routes' do
            expect(subject.call(env)).to eq(ok_resp)
          end
        end
      end

      context 'when no route matches' do
        let(:routes) { [not_matching_route] * 3 }

        context 'when no default route is set' do
          it 'returns a 404 Not Found with X-Cascade => pass' do
            resp = subject.call(env)
            expect(resp[0].to_i).to eq(404)
            expect(resp[1]['X-Cascade']).to eq('pass')
          end
        end

        context 'when a default route is set' do
          let(:default_response) { [200, {}, ['default response']] }
          let(:default_route) { instance_double(Route) }

          before { allow(default_route).to receive(:call).with(env) { default_response } }

          subject { Router.new(routes, default_route) }

          it 'returns the response from the default route' do
            expect(subject.call(env)).to eq(default_response)
          end
        end
      end
    end

    describe '#url_for' do
      let(:routes) { [instance_double(Route, name: 'first'),
                      route,
                      instance_double(Route, name: 'last')] }

      before do
        allow(route).to receive(:expand_url).with({}) { '/foo' }
        allow(route).to receive(:expand_url).with(id: '123') { '/foo/123' }
      end

      context 'when the route name is a symbol' do
        let(:route) { instance_double(Route, name: :foo) }

        it 'expands a route URL' do
          expect(subject.url_for(:foo)).to eq('/foo')
          expect(subject.url_for(:foo, id: '123')).to eq('/foo/123')
        end
      end

      context 'when the route name is a string' do
        let(:route) { instance_double(Route, name: 'foo') }

        it 'expands a route URL' do
          expect(subject.url_for('foo')).to eq('/foo')
          expect(subject.url_for('foo', id: '123')).to eq('/foo/123')
        end
      end
    end
  end
end
