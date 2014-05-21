module Nsque
  class Job
    ##
    # Inherit your worker class from this base class and you will be able to do
    # asynchronous jobs:
    #
    # class SomeJob < Nsque::Job
    #
    #   def self.arguments(object)
    #     {}
    #     # convert given object to arguments that will be passed to perform method
    #   end
    #
    #   def perform(*args)
    #     # some important work
    #   end
    # end
    #
    # And you will be able to make async calls like
    #
    #   SomeJob.process_async(cool_object)
    #
    # Note that process_async is a class method, perform is an instance method.
    # Also do not forget to implement arguments class method.
    # It takes object and converts it to something (usually Hash or Array) that
    # will be stored in the queue and will be passed to perform method of the job.

    def self.process_async(object)
      client_push('class' => self.to_s, 'args' => arguments(object))
    end

    def self.process_in(delay, object)
      at = (Time.now + delay).to_f
      item = { 'class' => self.to_s, 'args' => arguments(object), 'at' => at }
      client_push(item)
    end

  private

    def self.client_push(item)
      $producer.write(item)
    end

  end
end
