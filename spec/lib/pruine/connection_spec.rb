require "spec_helper"

describe Pruine::Connection do
  let(:connection) { described_class.new("START", {host: "0.0.0.0", port: 9292}) }
  let(:request_headers) { ["GET / HTTP/1.1" ,"Vines-User: user@example.com", "\r\n"] * "\r\n" }

  describe "#process_headers" do
    let(:callback) { Proc.new { 1 } }

    before { connection.process_headers(&callback) }
    after { connection.headers << request_headers }

    it { expect(callback).to receive :call }
  end
end
