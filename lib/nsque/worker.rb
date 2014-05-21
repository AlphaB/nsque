module Nsque
  class Worker

    def initialize(options)
      Krakow::Utils::Logging.level = options.delete(:logging_level) || :warn
      raise ChannelRequiredError.new unless options.has_key?(:channel)
      @options = options
    end

    def run
      consumer = Krakow::Consumer.new(@options)
      loop do
        message = consumer.queue.pop
        begin
          hash = JSON.parse(message.message)
          p hash.inspect
          enqueue_after = (hash['at'].to_f - Time.now.to_f) * 1000
          if enqueue_after <= 0
            klass = hash['class'].constantize
            klass.new.perform(hash['args'])
          else
            enqueue_after = [enqueue_after.to_i, 1.hour.to_i * 1000].min #FIXME NSQ max timeout is 1 hour
            p "Requeued: #{enqueue_after} ms"
            consumer.requeue(message, enqueue_after.to_i)
            next
          end
        rescue => e
          p e.message
        end
        consumer.confirm(message)
      end
    ensure
      consumer.terminate if consumer
    end
  end
end
