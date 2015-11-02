class Threads
  class << self
    def run_sync(thread_name = nil, &block)
      get_queue(thread_name).sync(&block)
    end

    def run_async(thread_name = nil, &block)
      get_queue(thread_name).async(&block)
    end

    def get_queue(thread_name = nil)
      @queues ||= {}
      if thread_name
        @queues[thread_name] ||= Dispatch::Queue.new(thread_name)
      else
        Dispatch::Queue.main
      end
    end
  end
end