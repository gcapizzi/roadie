require 'roadie/match'

module Roadie
  class VerbMatcher
    def initialize(verb)
      @verb = verb
    end

    def match(env)
      if @verb.eql?(env['REQUEST_METHOD'])
        Match.ok
      else
        Match.fail
      end
    end

    def expand(_ = nil);
      ''
    end
  end
end
