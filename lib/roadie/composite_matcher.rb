require 'mustermann'

require 'roadie/verb_matcher'
require 'roadie/path_matcher'

module Roadie
  class CompositeMatcher
    def initialize(matchers)
      @matchers = matchers
    end

    def match(env)
      @matchers.map { |m| m.match(env) }.reduce(:&)
    end

    def expand(params = nil)
      @matchers.map { |m| m.expand(params) }.reduce(:+)
    end
  end
end
