# coding: utf-8
require "em-proxy"

module Pruine
  # Public: The connection class for handling requests
  class Connection < EventMachine::ProxyServer::Connection
    attr_reader :headers

    # Public: Process request headers
    #
    # block - The block of ruby code
    #
    # Returns nothing
    def process_headers(&block)
      @headers = HeadersParser.new
      @headers.process(&block)
    end
  end
end
