require 'spec_helper'
require './lib/roadie'

module Roadie

  describe Router do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:matching_route) { double(Route, call: ok_resp) }
    let(:not_matching_route) { double(Route, call: [404, { 'X-Cascade' => 'pass' }, []]) }
    let(:env) { {} }

    describe '#call' do
      context 'when a route matches' do
        let(:other_matching_route) { double(Route, call: ok_resp) }

        before do
          subject << not_matching_route << matching_route << not_matching_route << other_matching_route
        end

        it 'stops trying and returns the route response' do
          other_matching_route.should_not_receive(:call)
          expect(subject.call(env)).to eq(ok_resp)
        end

        context 'when the matching route replies with X-Cascade => pass' do
          let(:ok_pass_resp) { [200, { 'X-Cascade' => 'pass' }, ['ok and pass']] }
          let(:matching_passing_route) { double(Route, call: ok_pass_resp) }

          before do
            subject << not_matching_route << matching_passing_route << not_matching_route << matching_route
          end

          it 'keeps trying other routes' do
            expect(subject.call(env)).to eq(ok_resp)
          end
        end
      end

      context 'when no route matches' do
        before do
          3.times { subject << not_matching_route }
        end

        context 'when no default route is set' do
          it 'returns a 404 Not Found with X-Cascade => pass' do
            resp = subject.call(env)
            expect(resp[0].to_i).to eq(404)
            expect(resp[1]['X-Cascade']).to eq('pass')
          end
        end

        context 'when a default route is set' do
          let(:default_resp) { [200, {}, ['default response']] }

          before do
            subject.default_route = double
            subject.default_route.stub(:call).with(env).and_return(default_resp)
          end

          it 'returns the response from the default route' do
            expect(subject.call(env)).to eq(default_resp)
          end
        end
      end
    end

    describe '#url_for' do
      let(:foo_route) { double(Route, name: :foo) }
      let(:bar_route) { double(Route, name: :bar) }

      before do
        foo_route.stub(:expand_url).with(id: '123').and_return('/foo/123')
        bar_route.stub(:expand_url).with(id: '456').and_return('/bar/456')
        subject << foo_route << bar_route
      end

      it 'expands a route URL' do
        expect(subject.url_for(:foo, id: '123')).to eq('/foo/123')
        expect(subject.url_for(:bar, id: '456')).to eq('/bar/456')
      end
    end
  end

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
        let(:matcher) { double(match: SuccessfulMatch.new(url_params)) }

        it 'sets params and returns the handler response' do
          handler.should_receive(:call).with('rack.routing_args' => url_params)
          expect(route.call(env)).to eq(ok_resp)
        end
      end

      context 'when the matcher doesn\'t match' do
        let(:matcher) { double(match: FailedMatch.new) }

        it 'returns a 404 Not Found with X-Cascade => pass' do
          resp = route.call(env)
          expect(resp[0].to_i).to eq(404)
          expect(resp[1]['X-Cascade']).to eq('pass')
        end
      end
    end

    describe '#expand_url' do
      before do
        matcher.stub(:expand).with(id: '123').and_return('/foo/123')
      end

      it 'expands the route URL' do
        expect(route.expand_url(id: '123')).to eq('/foo/123')
      end
    end
  end

  describe Matcher do
    subject { Matcher.new(Mustermann.new('/foo/:id'), methods: ['GET', 'POST']) }
    let(:match) { subject.match(request) }

    context 'when no methods are specified' do
      subject { Matcher.new(Mustermann.new('/foo')) }

      it 'matches only GETs' do
        expect(subject.match(req('GET', '/foo'))).to be_ok
        expect(subject.match(req('PUT', '/foo'))).not_to be_ok
      end
    end

    describe '#match' do
      context 'when the request matches' do
        let(:request) { req('POST', '/foo/123') }

        it 'returns a successful match with all needed params' do
          expect(match).to be_ok
          expect(match.params).to eq('id' => '123')
        end
      end

      shared_examples 'a match has failed' do
        it 'returns an failed match with no params' do
          expect(match).not_to be_ok
          expect(match.params).to be_empty
        end
      end

      context 'when the request doesn\'t match by method' do
        let(:request) { req('PUT', '/foo/123') }
        it_behaves_like 'a match has failed'
      end

      context 'when the request doesn\'t match by URL' do
        let(:request) { req('GET', '/bar/123') }
        it_behaves_like 'a match has failed'
      end
    end

    describe '#expand' do
      it 'expands the matcher URL' do
        expect(subject.expand(id: '123')).to eq('/foo/123')
      end

      context 'when the pattern has no placeholders and no params are passed' do
        subject { Matcher.new(Mustermann.new('/foo/bar'), methods: ['GET']) }

        it 'just returns the path' do
          expect(subject.expand).to eq('/foo/bar')
        end
      end
    end

    private

    def req(method, path)
      { 'REQUEST_METHOD' => method, 'PATH_INFO' => path }
    end
  end

  describe Match do
    it 'is not ok by default' do
      expect(Match.new.ok?).to be_false
    end

    describe '#initialize' do
      it 'sets the ok flag and the params' do
        params = { foo: 'bar' }
        match = Match.new(true, params)

        expect(match).to be_ok
        expect(match.params).to eq(params)
      end
    end
  end
end
