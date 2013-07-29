require "spec_helper"

describe Pruine do
  let(:pruine) { described_class.clone }
  let(:default_redis) { {host: "127.0.0.1", port: 6379} }

  describe "::setup" do
    context "when settings is default" do
      before { pruine.setup }

      it { expect(pruine.settings[:redis]).to eq default_redis }
    end

    context "when setup required once" do
      before { pruine.setup(redis: {host: "192.168.0.1", port: 9999}) }

      it { expect(pruine.settings[:redis]).to eq ({host: "192.168.0.1", port: 9999}) }
    end

    context "when setup required twice" do
      before { pruine.setup(redis: {host: "192.168.0.2", port: 9998}) }

      it { expect(pruine.settings[:redis]).to eq ({host: "192.168.0.2", port: 9998}) }
    end
  end
end
