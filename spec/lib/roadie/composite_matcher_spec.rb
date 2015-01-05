require 'spec_helper'
require 'rack'

require 'roadie/composite_matcher'

module Roadie
  RSpec.describe CompositeMatcher do
    let(:first_matcher) { double(:first_matcher) }
    let(:second_matcher) { double(:second_matcher) }
    let(:third_matcher) { double(:third_matcher) }
    subject { CompositeMatcher.new([first_matcher, second_matcher, third_matcher]) }

    describe '#match' do
      let(:env) { double }

      before do
        allow(first_matcher).to receive(:match).with(env) { Match.ok('first' => 1) }
        allow(second_matcher).to receive(:match).with(env) { Match.ok('second' => 2) }
        allow(third_matcher).to receive(:match).with(env) { Match.ok('third' => 3) }
      end

      it 'joins all matchers\' matches with #&' do
        expect(subject.match(env).params).to eq('first' => 1, 'second' => 2, 'third' => 3)
      end
    end

    describe '#expand' do
      context 'called without params' do
        before do
          allow(first_matcher).to receive(:expand).with(nil) { '' }
          allow(second_matcher).to receive(:expand).with(nil) { '/foo' }
          allow(third_matcher).to receive(:expand).with(nil) { '' }
        end

        it 'concats all matchers\' expansions' do
          expect(subject.expand).to eq('/foo')
        end
      end

      context 'called with a params hash' do
        let(:params) { { 'id' => 123 } }

        before do
          allow(first_matcher).to receive(:expand).with(params) { '' }
          allow(second_matcher).to receive(:expand).with(params) { '/foo' }
          allow(third_matcher).to receive(:expand).with(params) { '' }
        end

        it 'concats all matchers\' expansions' do
          expect(subject.expand(params)).to eq('/foo')
        end
      end
    end
  end
end
