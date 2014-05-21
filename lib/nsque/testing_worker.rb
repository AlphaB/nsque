module Nsque
  class TestingWorker
    # use this worker in your test to process delayed jobs

    def initialize(options)
      raise ChannelRequiredError.new unless options.has_key?(:channel)
      @options = options
      raise ProducerCantBeNilError.new if options[:producer].nil?
      @producer = options[:producer]
      @consumer = Krakow::Consumer.new(@options)
    end

    def process_all
      count = 0
      while @producer.messages_count > count
        message = @consumer.queue.pop
        hash = JSON.parse(message.message)
        begin
          klass = hash['class'].constantize
          klass.new.perform(hash['args'])
        rescue
        end
        @consumer.confirm(message)
        count += 1
      end

      @producer.reset_counters
      count
    end

    def clear_all
      count = 0

      while @producer.messages_count > count
        message = @consumer.queue.pop
        @consumer.confirm(message)

        count += 1
      end

      @producer.reset_counters
      count
    end
  end
end
