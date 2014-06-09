module Nsque
  class Producer
    attr_reader :messages_count

    def initialize(options = {})
      @producer = Nsqrb::Producer.new(options[:host], options[:port], options[:topic])
      @messages_count = 0
    end

    def write(item)
      message = JSON.generate(item)
      @producer.post!(message)
      @messages_count += 1
    end

    def reset_counters
      @messages_count = 0
    end
  end
end
