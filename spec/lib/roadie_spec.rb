require './lib/roadie'

module Roadie

  describe Router do
    context 'when no route is defined' do
      let(:env) { double('env') }
      let(:router) { Router.new }

      it 'returns a 404 by default' do
        expect(router.call(env)[0].to_i).to eq(404)
      end
    end

    context 'when some routes are defined' do
      let(:ok_resp) { [200, {}, ['ok']] }
      let(:not_found_resp) { [404, {}, []] }
      let(:ok_route) { double(Route, call: ok_resp) }
      let(:other_ok_route) { double(Route, call: ok_resp) }
      let(:not_found_route) { double(Route, call: not_found_resp) }
      let(:env) { double('env') }

      context 'when some route matches' do
        let(:router) { Router.new(not_found_route, ok_route, not_found_route, ok_route) }

        it 'tries all routes one by one, stops at the first matching' do
          other_ok_route.should_not_receive(:call)
          expect(router.call(env)).to eq(ok_resp)
        end
      end

      context 'when no route matches' do
        let(:router) { Router.new(not_found_route, not_found_route, not_found_route) }

        it 'returns a 404 Not Found if not route matches' do
          expect(router.call(env)[0].to_i).to eq(404)
        end
      end
    end
  end

  describe Route do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:handler) { double(call: ok_resp) }
    let(:route) { Route.new(:foo, matcher, handler) }
    let(:env) { double('env') }

    context 'when the matcher matches' do
      let(:params) { { 'foo' => 'bar' } }
      let(:matcher) { double(matches?: true, params: params) }

      it 'sets params and returns the handler response' do
        env.should_receive(:[]=).with('roadie.params', params)
        expect(route.call(env)).to eq(ok_resp)
      end
    end

    context 'when the matcher doesn\'t match' do
      let(:matcher) { double(matches?: false) }

      it 'returns a 404 Not Found' do
        expect(route.call(env)[0].to_i).to eq(404)
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
