# coding: utf-8
require "forwardable"
require "em-synchrony"

module HttpProxy
  extend self
  extend Forwardable

  def_delegators Trapper, :trap, :attach_signal_handlers

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
      attach_signal_handlers

      EventMachine::start_server(options[:host], options[:port], Connection, options) do |proxy|
        proxy.on_data do |data|
          proxy.headers << data
          data
        end

        proxy.instance_eval(&block)
      end
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
