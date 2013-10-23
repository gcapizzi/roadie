require './lib/roadie/router'

module Roadie

  describe Router do
    let(:ok_resp) { [200, {}, ['ok']] }
    let(:matching_route) { double(Route, call: ok_resp) }
    let(:not_matching_route) { double(Route, call: [404, { 'X-Cascade' => 'pass' }, []]) }
    let(:env) { {} }

    describe '#call' do
      context 'when a route matches' do
        let(:other_matching_route) { double(Route, call: ok_resp) }

        before do
          subject << not_matching_route << matching_route << not_matching_route << other_matching_route
        end

        it 'stops trying and returns the route response' do
          other_matching_route.should_not_receive(:call)
          expect(subject.call(env)).to eq(ok_resp)
        end

        context 'when the matching route replies with X-Cascade => pass' do
          let(:ok_pass_resp) { [200, { 'X-Cascade' => 'pass' }, ['ok and pass']] }
          let(:matching_passing_route) { double(Route, call: ok_pass_resp) }

          before do
            subject << not_matching_route << matching_passing_route << not_matching_route << matching_route
          end

          it 'keeps trying other routes' do
            expect(subject.call(env)).to eq(ok_resp)
          end
        end
      end

      context 'when no route matches' do
        before do
          3.times { subject << not_matching_route }
        end

        context 'when no default route is set' do
          it 'returns a 404 Not Found with X-Cascade => pass' do
            resp = subject.call(env)
            expect(resp[0].to_i).to eq(404)
            expect(resp[1]['X-Cascade']).to eq('pass')
          end
        end

        context 'when a default route is set' do
          let(:default_resp) { [200, {}, ['default response']] }

          before do
            subject.default_route = double
            subject.default_route.stub(:call).with(env).and_return(default_resp)
          end

          it 'returns the response from the default route' do
            expect(subject.call(env)).to eq(default_resp)
          end
        end
      end
    end

    describe '#url_for' do
      let(:foo_route) { double(Route, name: :foo) }
      let(:bar_route) { double(Route, name: :bar) }

      before do
        foo_route.stub(:expand_url).with(id: '123').and_return('/foo/123')
        bar_route.stub(:expand_url).with(id: '456').and_return('/bar/456')
        subject << foo_route << bar_route
      end

      it 'expands a route URL' do
        expect(subject.url_for(:foo, id: '123')).to eq('/foo/123')
        expect(subject.url_for(:bar, id: '456')).to eq('/bar/456')
      end
    end
  end

end
