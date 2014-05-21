module Nsque
  class Error < RuntimeError
  end

  class ChannelRequiredError < Error; end
  class ProducerCantBeNilError < Error; end
end
