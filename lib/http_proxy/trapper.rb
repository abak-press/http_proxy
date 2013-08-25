# coding: utf-8

module HttpProxy
  # Public: The signal handler
  module Trapper
    extend self

    # Public: The signal separator in pipe
    SIGNAL_SEPARATOR = ".".freeze

    # Public: The inverse associated signals list
    SIGNALS_INVERTED_LIST = Signal.list.invert.freeze

    # Public The list of handlers
    attr_reader :handlers

    # Public: Add signal handler
    #
    # signal - [String|Symbol] the name of signal
    # block  - Block the block of code
    #
    # Returns nothing
    def trap(signal, &block)
      @handlers ||= Hash.new
      @handlers[convert signal] = block
    end

    # Public: Initiate signal handling
    #
    # Returns nothing
    def attach_signal_handlers
      r, w = IO.pipe

      EM.attach(r, self)
      EM.attach(w) do |x|
        @handlers.keys.each do |signal|
          Signal.trap(signal) { x.send_data("#{signal}#{SIGNAL_SEPARATOR}") }
        end
      end
    end

    private
    # Internal: Convert signal into string representation
    #
    # signal - [String|Symbol|Fixnum] the signal name or code
    #
    # Returns String
    def convert(signal)
      return signal.to_s unless signal.is_a? Fixnum

      SIGNALS_INVERTED_LIST[signal] or raise ArgumentError, "unsupported signal #{signal}"
    end

    # Internal: Process new signal data from pipe
    #
    # data - String the data from pipe
    #
    # Returns nothing
    def receive_data(data)
      data.split(SIGNAL_SEPARATOR).each do |s|
        EM.next_tick { Trapper.handlers[s].call if Trapper.handlers.key?(s) }
      end
    end
  end
end