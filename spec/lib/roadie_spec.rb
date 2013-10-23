require 'spec_helper'
require './lib/roadie'

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
        matcher.stub(:expand).with({}).and_return('/foo')
        matcher.stub(:expand).with(id: '123').and_return('/foo/123')
      end

      it 'expands the route URL' do
        expect(route.expand_url).to eq('/foo')
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
      expect(Match.new.ok?).to be(false)
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
