module Nsque
  class Worker

    def initialize(options)
      Krakow::Utils::Logging.level = options.delete(:logging_level) || :warn
      raise ChannelRequiredError.new unless options.has_key?(:channel)
      @options = options
    end

    def run
      consumer = Krakow::Consumer.new(@options)
      initialize_traps

      loop do
        begin
          message = Timeout::timeout(1) { consumer.queue.pop }
        rescue Timeout::Error
          break if @shutdown
          next if message.nil?
        end
        begin
          hash = JSON.parse(message.message)
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
        break if @shutdown
      end
    ensure
      consumer.terminate if consumer
    end

    private

      def initialize_traps
        %w(INT TERM).each do |signal|
          trap(signal) do
            puts "I've recieved #{signal}!"
            @shutdown = true
          end
        end
      end
  end
end
