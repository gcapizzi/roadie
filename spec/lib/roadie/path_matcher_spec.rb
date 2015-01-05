require 'spec_helper'
require 'rack'

require 'roadie/path_matcher'

module Roadie
  RSpec.describe PathMatcher do
    subject { PathMatcher.new('/foo/:id') }

    describe '#match' do
      let(:match) { subject.match(request) }

      context 'when the request matches' do
        let(:request) { req('GET', '/foo/123') }

        it 'returns a successful match' do
          expect(match).to be_ok
          expect(match.params).to eq('id' => '123')
        end
      end

      context 'when the request doesn\'t match' do
        let(:request) { req('GET', '/bar/123') }

        it 'returns an failed match' do
          expect(match).not_to be_ok
        end
      end
    end

    describe '#expand' do
      context 'called without params' do
        subject { PathMatcher.new('/foo') }

        it 'expands the matcher URL' do
          expect(subject.expand).to eq('/foo')
        end
      end

      context 'called with a params hash' do
        it 'expands the matcher URL' do
          expect(subject.expand(id: 123)).to eq('/foo/123')
        end
      end
    end
  end
end
