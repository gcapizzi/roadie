require 'spec_helper'
require 'roadie/match'

module Roadie
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
