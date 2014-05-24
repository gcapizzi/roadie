require 'spec_helper'
require 'roadie/router'

module Roadie
  describe Router do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:matching_route) { double(Route, call: ok_resp) }
    let(:pass_resp) { [404, { 'X-Cascade' => 'pass' }, []] }
    let(:not_matching_route) { double(Route, call: pass_resp) }
    let(:env) { {} }

    subject { Router.new(routes) }

    describe '#call' do
      context 'when a route matches' do
        let(:other_matching_route) { double(Route, call: ok_resp) }
        let(:routes) do
          [not_matching_route,
           matching_route,
           not_matching_route,
           other_matching_route]
        end

        it 'stops trying and returns the route response' do
          other_matching_route.should_not_receive(:call)
          expect(subject.call(env)).to eq(ok_resp)
        end

        context 'when a matching route replies with X-Cascade => pass' do
          let(:ok_pass_resp) { [200, { 'X-Cascade' => 'pass' }, []] }
          let(:passing_route) { double(Route, call: ok_pass_resp) }
          let(:routes) { [passing_route, matching_route] }

          it 'keeps trying other routes' do
            expect(subject.call(env)).to eq(ok_resp)
          end
        end

        context 'when a route uses X-Cascade with the wrong value' do
          let(:wrong_pass_resp) { [200, { 'X-Cascade' => 'wrong' }, []] }
          let(:wrong_pass_route) { double(Route, call: wrong_pass_resp) }
          let(:routes) { [wrong_pass_route, matching_route] }

          it 'ignores the X-Cascade directive' do
            response = subject.call(env)
            expect(response[1]['X-Cascade']).to eq('wrong')
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
          let(:default_resp) { [200, {}, ['default response']] }
          let(:default_route) { double(Route) }

          before { default_route.stub(:call).with(env) { default_resp } }

          subject { Router.new(routes, default_route) }

          it 'returns the response from the default route' do
            expect(subject.call(env)).to eq(default_resp)
          end
        end
      end
    end

    describe '#url_for' do
      let(:routes) { [double(Route, name: 'first'), route, double(Route, name: 'last')] }

      before { allow(route).to receive(:expand_url).with(id: '123') { '/foo/123' } }

      context 'when the route name is a symbol' do
        let(:route) { double(Route, name: :foo) }

        it 'expands a route URL' do
          expect(subject.url_for(:foo, id: '123')).to eq('/foo/123')
        end
      end

      context 'when the route name is a string' do
        let(:route) { double(Route, name: 'foo') }

        it 'expands a route URL' do
          expect(subject.url_for('foo', id: '123')).to eq('/foo/123')
        end
      end
    end
  end
end
