require 'roadie/pass_route'

RSpec.describe PassRoute do
  describe '#call' do
    it 'always returns a 404 with X-Cascade => pass' do
      response = subject.call(nil)

      expect(response[0]).to eq(404)
      expect(response[1]['X-Cascade']).to eq('pass')
      expect(response[2].first).to eq('Not Found')
    end
  end

  describe '#expand_url' do
    it 'always returns nil' do
      expect(subject.expand_url(nil, nil)).to be(nil)
    end
  end
end
