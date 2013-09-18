require "spec_helper"

describe HttpProxy::Connection do
  let(:connection) { described_class.new("START", {host: "0.0.0.0", port: 9292}) }
  let(:request_headers) { ["GET / HTTP/1.1", "Vines-User: user@example.com", "\r\n"] * "\r\n" }

  before { stub_const("HttpProxy::Connection", HttpProxy::Connection.clone) }

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

  describe "#fallback" do
    context "when fallback is set" do
      let(:error) { RuntimeError.new("Unknown Error") }
      let(:backend) { {host: "unknown.host", port: 9595} }

      before do
        connection.stub(:server).and_raise error
        connection.stub(:close_connection)

        connection.stub(:backends).and_return(Hash.new)
        connection.route_to backend
      end

      it "should yield given fallback block" do
        expect do |b|
          connection.fallback(&b)
          connection.process { "nothing" }
          connection.receive_data(request_headers)
        end.to yield_with_args error, backend
      end
    end

    context "when fallback is not set" do
      before do
        connection.stub(:server).and_raise RuntimeError
        connection.stub(:close_connection)

        connection.stub(:backends).and_return(Hash.new)
        connection.route_to host: "unknown.host", port: 9595
      end

      it "should re-rise exception" do
        expect do
          connection.process { "nothing" }
          connection.receive_data(request_headers)
        end.to raise_error RuntimeError
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
