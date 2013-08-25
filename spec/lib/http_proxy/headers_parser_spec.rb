# coding: utf-8
require "spec_helper"

describe HttpProxy::HeadersParser do
  let(:request_headers) { ["GET / HTTP/1.1" ,"Vines-User: user@example.com", "\r\n"] * "\r\n" }
  let(:headers) { described_class.new }

  describe "#initialize" do
    it { expect(headers.buffer).to be_empty }
  end

  describe "#<<" do
    before { headers << "Custom-Header: Hello\n\r\n\r" }

    it { expect(headers.buffer).to eq "Custom-Header: Hello\n\r\n\r" }
  end

  describe "#process" do
    let(:callback) { Proc.new { 1 } }

    before { headers.process(&callback) }
    after { headers << request_headers }

    it { expect(callback).to receive :call }
  end
end
