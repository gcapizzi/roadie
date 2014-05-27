require 'spec_helper'
require 'rack'

require 'roadie/matcher'

module Roadie
  RSpec.describe Matcher do
    let(:path_pattern) { '/foo/:id' }
    let(:methods) { %w(GET POST) }
    subject { Matcher.new(path_pattern, methods) }
    let(:match) { subject.match(request) }

    describe '#initialize' do
      it 'sets the Matcher path_pattern and methods' do
        expect(subject.path_pattern).to be_a(Mustermann::Pattern)
        expect(subject.path_pattern.to_s).to eq(path_pattern)
        expect(subject.methods).to eq(methods)
      end

      context 'when the methods param does not respond to #each' do
        it 'raises an error' do
          expect { Matcher.new('/foo', 'FOO') }.to raise_error('The methods param should respond to #each')
        end
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

      context 'when the pattern has no placeholders and params is empty' do
        subject { Matcher.new('/foo/bar', ['GET']) }

        it 'just returns the path' do
          expect(subject.expand).to eq('/foo/bar')
        end
      end
    end
  end
end
