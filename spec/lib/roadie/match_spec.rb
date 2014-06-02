require 'spec_helper'

require 'roadie/match'

module Roadie
  RSpec.describe Match do
    let(:params) { { foo: 'bar' } }

    describe Match::Ok do
      describe '#initialize' do
        context 'when called without params' do
          it 'leaves the match params empty' do
            expect(subject.params).to be_empty
          end
        end

        context 'when called with a params hash' do
          subject { Match::Ok.new(params) }

          it 'sets the match params' do
            expect(subject.params).to eq(params)
          end
        end
      end

      describe '#ok?' do
        it 'returns true' do
          expect(subject.ok?).to be(true)
        end
      end
    end

    describe Match::Fail do
      describe '#ok?' do
        it 'returns false' do
          expect(subject.ok?).to be(false)
        end
      end
    end

    describe '.ok' do
      it 'creates a Match::Ok' do
        expect(Match.ok).to be_a(Match::Ok)
        expect(Match.ok.params).to be_empty
      end

      it 'sets the params' do
        expect(Match.ok(params).params).to eq(params)
      end
    end

    describe '.fail' do
      it 'creates a Match::Fail' do
        expect(Match.fail).to be_a(Match::Fail)
      end
    end
  end
end
