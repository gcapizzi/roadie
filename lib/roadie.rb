require 'roadie/builder'

module Roadie
  def self.build(&block)
    Builder.new.build(&block)
  end
end
