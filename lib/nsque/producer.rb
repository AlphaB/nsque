module Nsque
  class Producer
    attr_reader :messages_count

    def initialize(options = {})
      Krakow::Utils::Logging.level = options.delete(:logging_level) || :warn
      @producer = Krakow::Producer.new(options)
      @messages_count = 0
    end

    def write(item)
      message = JSON.generate(item)
      @producer.write(message)
      @messages_count += 1
    end

    def reset_counters
      @messages_count = 0
    end
  end
end
