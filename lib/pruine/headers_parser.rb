# coding: utf-8
require "http/parser"

module Pruine
  # Public: The requesr headers parser
  class HeadersParser
    attr_reader :buffer

    def initialize
      @parser = Http::Parser.new
      @buffer = String.new
    end

    # Public: Add new data to parser
    #
    # data - String the headers data
    #
    # Returns nothing
    def <<(data)
      @parser << data
      @buffer << data
    end

    # Public: Setup callback for headers parsing complete
    #
    # block - Block the block of code
    #
    # Examples
    #
    # headers = Pruine::HeadersParser.new
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
