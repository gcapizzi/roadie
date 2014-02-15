require 'spec_helper'
require 'roadie/match'

module Roadie
  describe Match do
    let(:params) { { foo: 'bar' } }

    describe '#initialize' do
      it 'sets the ok flag' do
        expect(Match.new(true)).to be_ok
      end

      it 'sets the params' do
        expect(Match.new(true, params).params).to eq(params)
      end

      it 'creates a failed match by default' do
        expect(Match.new).not_to be_ok
        expect(Match.new.params).to be_empty
      end
    end

    describe '.ok' do
      it 'creates a successful match' do
        expect(Match.ok).to be_ok
      end

      it 'sets the params' do
        expect(Match.ok.params).to be_empty
        expect(Match.ok(params).params).to eq(params)
      end
    end

    describe '.fail' do
      it 'creates a failed match' do
        expect(Match.fail).not_to be_ok
      end
    end
  end
end
