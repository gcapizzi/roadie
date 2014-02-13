require 'spec_helper'
require 'rack'

require 'roadie/matcher'

module Roadie
  describe Matcher do
    subject { Matcher.new('/foo/:id', methods: ['GET', 'POST']) }
    let(:match) { subject.match(request) }

    context 'when no methods are specified' do
      subject { Matcher.new('/foo') }

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
        subject { Matcher.new('/foo/bar', methods: ['GET']) }

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
end
