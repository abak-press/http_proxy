# coding: utf-8
require "http/parser"

module HttpProxy
  # Public: The requesr headers parser
  class HeadersParser
    attr_reader :buffer

    def initialize
      @parser = Http::Parser.new
      @buffer = String.new
    end

    # Public: Add new raw-data to parser
    #
    # data - String the request headers data
    #
    # Returns nothing
    def <<(data)
      @parser << data
      @buffer << data
    end

    # Public: Setup callback on headers parsing complete
    #
    # block - Block the block of code
    #
    # Examples
    #
    # headers = HttpProxy::HeadersParser.new
    # headers.process do |parsing_result|
    #   p parsing_result["User-Agent"]
    # end
    #
    # Returns nothing
    def process(&block)
      @parser.on_headers_complete = block
    end
  end
end
