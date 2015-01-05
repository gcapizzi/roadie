require 'spec_helper'
require 'rack'

require 'roadie/verb_matcher'

module Roadie
  RSpec.describe VerbMatcher do
    subject { VerbMatcher.new('GET') }

    describe '#match' do
      let(:match) { subject.match(request) }

      context 'when the request matches' do
        let(:request) { req('GET', '/foo') }

        it 'returns a successful match' do
          expect(match).to be_ok
          expect(match.params).to be_empty
        end
      end

      context 'when the request doesn\'t match' do
        let(:request) { req('POST', '/foo') }

        it 'returns an failed match' do
          expect(match).not_to be_ok
        end
      end
    end

    describe '#expand' do
      it 'always returns an empty string' do
        expect(subject.expand).to eq('')
        expect(subject.expand('foo' => 'bar')).to eq('')
      end
    end
  end
end
