require './lib/roadie'

module Roadie

  describe Router do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:pass_resp) { [404, { 'X-Cascade' => 'pass' }, []] }
    let(:ok_pass_resp) { [200, { 'X-Cascade' => 'pass' }, ['ok and pass']] }
    let(:matching_route) { double(Route, call: ok_resp) }
    let(:other_matching_route) { double(Route, call: ok_resp) }
    let(:not_matching_route) { double(Route, call: pass_resp) }
    let(:matching_passing_route) { double(Route, call: ok_pass_resp) }
    let(:env) { double('env') }

    context 'when no route is defined' do
      let(:router) { Router.new }

      it 'returns a 404 Not Found with X-Cascade => pass' do
        resp = router.call(env)
        expect(resp[0].to_i).to eq(404)
        expect(resp[1]['X-Cascade']).to eq('pass')
      end
    end

    context 'when a route matches' do
      let(:router) { Router.new([not_matching_route, matching_route, not_matching_route, other_matching_route]) }

      it 'tries all routes one by one, stops at the first matching' do
        other_matching_route.should_not_receive(:call)
        expect(router.call(env)).to eq(ok_resp)
      end

      context 'when the matching route replies with X-Cascade => pass' do
        let(:router) { Router.new([not_matching_route, matching_passing_route, not_matching_route, matching_route]) }

        it 'keeps trying other routes' do
          expect(router.call(env)).to eq(ok_resp)
        end
      end
    end

    context 'when no route matches' do
      let(:router) { Router.new([not_matching_route, not_matching_route, not_matching_route]) }

      it 'returns a 404 Not Found with X-Cascade => pass' do
        resp = router.call(env)
        expect(resp[0].to_i).to eq(404)
        expect(resp[1]['X-Cascade']).to eq('pass')
      end
    end
  end

  describe Route do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:handler) { double('handler', call: ok_resp) }
    let(:route) { Route.new(:foo, matcher, handler) }
    let(:env) { double('env') }

    context 'when the matcher matches' do
      let(:params) { { 'foo' => 'bar' } }
      let(:matcher) { double(matches?: true, params: params) }

      it 'sets params and returns the handler response' do
        env.should_receive(:[]=).with('rack.routing_args', params)
        expect(route.call(env)).to eq(ok_resp)
      end
    end

    context 'when the matcher doesn\'t match' do
      let(:matcher) { double(matches?: false) }

      it 'returns a 404 Not Found with X-Cascade => pass' do
        resp = route.call(env)
        expect(resp[0].to_i).to eq(404)
        expect(resp[1]['X-Cascade']).to eq('pass')
      end
    end
  end

  describe Matcher do
    describe '#matches?' do
      context 'with a string path and a string verb' do
        let(:matcher) { Matcher.new('POST', '/foo') }

        it 'matches a request' do
          expect(matcher.matches?(req('POST', '/bar'))).to be_false
          expect(matcher.matches?(req('GET',  '/foo'))).to be_false
          expect(matcher.matches?(req('POST', '/foo'))).to be_true
        end
      end

      context 'with a regex path and a string verb' do
        let(:matcher) { Matcher.new('POST', %r{/foo(/(.+))?}) }

        it 'matches a request' do
          expect(matcher.matches?(req('POST', '/foo'    ))).to be_true
          expect(matcher.matches?(req('POST', '/foo/'   ))).to be_true
          expect(matcher.matches?(req('POST', '/foo/bar'))).to be_true
          expect(matcher.matches?(req('GET',  '/foo'    ))).to be_false
          expect(matcher.matches?(req('POST', '/bar'    ))).to be_false
        end
      end

      context 'with a regex path and a regex verb' do
        let(:matcher) { Matcher.new(/.+/, %r{/foo(/(.+))?}) }

        it 'matches a request' do
          expect(matcher.matches?(req('GET',  '/foo' ))).to be_true
          expect(matcher.matches?(req('POST', '/foo/'))).to be_true
          expect(matcher.matches?(req('',     '/foo/'))).to be_false
        end
      end
    end

    describe '#params' do
      let(:matcher) { Matcher.new(/(?<verb>.+)/, %r{/resource/(?<id>.+)/?}) }

      it 'returns a hash of captures' do
        expect(matcher.params(req('GET', '/resource/123'))).to eq('verb' => 'GET', 'id' => '123')
      end
    end

    private

    def req(verb, path)
      { 'REQUEST_METHOD' => verb, 'PATH_INFO' => path }
    end
  end

end
