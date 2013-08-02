# coding: utf-8
require "em-synchrony"

module HttpProxy
  extend self

  # Public: User defined signals
  SIGNALS = [:sighup, :sigusr1, :sigusr2].freeze

  # Public: Start the em-proxy server
  #
  # options - Hash the options hash
  #           :host  - String the proxy server host
  #           :port  - [String|Fixnum] the proxy server port
  #           :debug - boolean the debug mode flag
  #
  # Returns nothing
  def start(options, &block)
    puts "Starting Proxy server"

    EM.epoll
    EM.synchrony do
      trap("TERM") { stop }
      trap("INT")  { stop }

      SIGNALS.each do |signal|
        trap(signal[3..-1].upcase) { HttpProxy.send(signal) }
      end

      EventMachine::start_server(options[:host], options[:port], Connection, options) do |proxy|
        proxy.on_data do |data|
          proxy.headers << data
          data
        end

        proxy.instance_eval(&block)
      end
    end
  end
  
  SIGNALS.each do |signal|
    # Public: Call block assigned on signal
    #
    # Returns nothing
    # def sighup
    #  if @sig_handlers.key?(:sighup)
    #    puts "Processing SIGHUP signal"
    #
    #    @sig_handlers[:sighup].call
    # end
    define_method(signal) do
      if @sig_handlers.key?(signal)
        puts "Processing #{signal.to_s.upcase} signal"

        @sig_handlers[signal].call
      end
    end

    # Public: Attach block to signal
    #
    # block - [Block|Proc] the block of code
    #
    # Returns nothing
    # def on_sighup(&block)
    #   @sig_handlers ||= Hash.new
    #   @sig_handlers[:sighup] = block
    # end
    define_method("on_#{signal}") do |&block|
      @sig_handlers ||= Hash.new
      @sig_handlers[signal] = block
    end
  end

  # Public: Stop the em-proxy server
  #
  # Returns nothing
  def stop
    puts "Terminating Proxy server"

    EM.stop
  end
end
