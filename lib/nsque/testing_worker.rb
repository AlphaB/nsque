module Nsque
  class TestingWorker
    # use this worker in your test to process delayed jobs

    def initialize(options)
      raise ChannelRequiredError.new unless options.has_key?(:channel)
      raise ProducerCantBeNilError.new if options[:producer].nil?
      @options = options
      @producer = options[:producer]
      @consumer = Nsqrb::Consumer.new(@options)
      @consumer.connect!
    end

    def process_all
      count = 0
      while @producer.messages_count > count
        @consumer.receive
        message = @consumer.messages.pop
        next unless message
        hash = JSON.parse(message.content)
        begin
          klass = hash['class'].constantize
          klass.new.perform(hash['args'])
        rescue => e
          puts e.inspect
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
        @consumer.receive
        message = @consumer.messages.pop
        next unless message
        @consumer.confirm(message)
        count += 1
      end

      @producer.reset_counters
      count
    end
  end
end
