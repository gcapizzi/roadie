require 'spec_helper'
require 'roadie/match'

module Roadie
  describe Match do
    let(:params) { { foo: 'bar' } }

    describe '#initialize' do
      it 'sets the ok flag and the params' do
        match = Match.new(true, params)

        expect(match).to be_ok
        expect(match.params).to eq(params)
      end

      it 'creates a failed match by default' do
        expect(Match.new).not_to be_ok
      end
    end

    describe '.ok' do
      it 'creates a successful match' do
        match = Match.ok(params)

        expect(match).to be_ok
        expect(match.params).to eq(params)
      end
    end

    describe '.fail' do
      it 'creates a failed match' do
        expect(Match.fail).not_to be_ok
      end
    end
  end
end
