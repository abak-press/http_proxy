require "spec_helper"

describe Vitis::Connection do
  let(:connection) { described_class.new("START", {host: "0.0.0.0", port: 9292}) }
  let(:request_headers) { ["GET / HTTP/1.1", "Vines-User: user@example.com", "\r\n"] * "\r\n" }

  before { stub_const("Vitis::Connection", Vitis::Connection.clone) }

  describe "#backend & #backends" do
    context "when backend is not set" do
      it { expect { connection.backends }.to raise_error RuntimeError, "Backends list is empty" }
    end

    context "when backend is set once" do
      before { connection.backend(:one, {h: 1, p: 2}) }

      it { expect(connection.backends.count).to eq 1 }
    end

    context "when backend is set twice" do
      before { connection.backend(:one, {h: 1, p: 2}) }
      before { connection.backend(:two, {h: 1, p: 2}) }

      it { expect(connection.backends.count).to eq 2 }
    end
  end

  describe "#process" do
    before do
      connection.stub(:server)
      connection.stub(:relay_to_servers)
      connection.stub(:close_connection)

      connection.stub(:backends).and_return(one: {h: "1", p: 2})
      connection.route_to :one
    end

    context "when process unknown type" do
      it { expect { connection.process(:unknown) }.to raise_error TypeError, "Unknown pre-processing type" }
    end

    context "when process raw data" do
      it "should yield given block when headers parsed" do
        expect do |b|
          connection.process(&b)
          connection.receive_data(request_headers)
        end.to yield_control
      end
    end

    context "when process all headers" do
      it "should yield given block when headers parsed" do
        expect do |b|
          connection.process(:headers, &b)
          connection.headers << request_headers
        end.to yield_control
      end
    end

    context "when process specific header key" do
      it "should not yield given block when headers key not found" do
        expect do |b|
          connection.process(:header, "User", &b)
          connection.headers << request_headers
        end.not_to yield_control
      end

      it "should yield given block when headers key found" do
        expect do |b|
          connection.process(:header, "Vines-User", &b)
          connection.headers << request_headers
        end.to yield_control
      end
    end
  end

  describe "#if_present" do
    before { connection.stub(:close_connection) }

    it { expect { |b| connection.send(:if_present, 1, &b) }.to yield_control }
    it { expect { |b| connection.send(:if_present, false, &b) }.not_to yield_control }
    it { expect { |b| connection.send(:if_present, nil, &b) }.not_to yield_control }
  end
end
