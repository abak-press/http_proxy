# coding: utf-8

module HttpProxy
  # Public: The signal handler
  module Trapper
    extend self

    # Public: The signal separator in pipe
    SIGNAL_SEPARATOR = ".".freeze

    # Public: Add signal handler
    #
    # signal - [String|Symbol] the name of signal
    # block  - Block the block of code
    #
    # Returns nothing
    def trap(signal, &block)
      @handlers ||= Hash.new
      @handlers[signal.to_s] = block
    end

    # Public: Initiate signal handling
    #
    # Returns nothing
    def attach_signal_handlers
      pipe = IO.pipe

      wr = EM.attach(pipe[1])
      rd = EM.attach(pipe[0]) do |x|
        def x.receive_data(data)
          data.split(SIGNAL_SEPARATOR).each do |s|
            EM.next_tick { Trapper.handle(s) }
          end
        end
      end

      @handlers.keys.each do |signal|
        Signal.trap(signal) { wr.send_data("#{signal}#{SIGNAL_SEPARATOR}") }
      end
    end

    # Internal: Handle concrete signal
    #
    # signal - String the name of signal
    #
    # Returns nothing
    def handle(signal)
      @handlers[signal].call if @handlers.has_key?(signal)
    end
  end
end