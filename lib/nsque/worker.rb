module Nsque
  class Worker

    def initialize(options)
      raise ChannelRequiredError.new unless options.has_key?(:channel)
      @options = options
    end

    def run
      initialize_traps
      consumer = Nsqrb::Consumer.new(@options)
      consumer.connect!

      loop do
        consumer.receive

        while message = consumer.messages.pop
          @processing_message = true
          begin
            hash = JSON.parse(message.content)
            puts hash.inspect
            enqueue_after = (hash['at'].to_f - Time.now.to_f) * 1000
            if enqueue_after <= 0
              klass = hash['class'].constantize
              klass.new.perform(hash['args'])
            else
              puts "Requeued: #{enqueue_after} ms"
              consumer.requeue(message, enqueue_after.to_i)
              next
            end
          rescue => e
            p e.message
          end
          consumer.confirm(message)
          @processing_message = false
        end
        break if @shutdown
      end
    ensure
      consumer.close! if consumer
    end

    private

      def initialize_traps
        %w(INT TERM).each do |signal|
          trap(signal) do
            puts "I've recieved #{signal}!"
            @shutdown = true
            exit unless @processing_message
          end
        end
      end
  end
end
