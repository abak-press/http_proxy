require "spec_helper"

describe Pruine::Cluster do
  let(:cluster) { described_class.clone }
  let(:redis) { MockRedis.new }

  before { Pruine.stub(:redis).and_return redis }

  describe "::nodes" do
    context "when nodes doesn't exists" do
      before { Pruine.stub(:settings).and_return Hash.new }

      it { expect { cluster.nodes }.to raise_error KeyError }
    end

    context "when nodes exists" do
      let(:settings) do
        {nodes: {
          node_0: {host: "0.0.0.0", port: 1111},
          node_1: {host: "0.0.0.0", port: 1112}
        }}
      end
      before { Pruine.stub(:settings).and_return settings }

      it { expect(cluster.nodes.count).to eq 2 }
    end
  end

  describe "::touch" do
    context "when node exists" do
      before { redis.hset(cluster::CAPACITY, :node_0, 0) }

      it { expect(cluster.touch(:node_0)).to eq 1 }
    end

    context "when node doesn't exists" do
      it { expect(cluster.touch(:node_0)).to eq 1 }
    end

    context "when node touched twice ore more" do
      it "should increase node entry counter twice" do
        expect(cluster.touch(:node_0)).to eq 1
        expect(cluster.touch(:node_0)).to eq 2
      end
    end
  end

  describe "::capacity" do
    before do
      redis.hset(cluster::CAPACITY, :node_0, 0)
      redis.hset(cluster::CAPACITY, :node_1, 1)
    end

    it { expect(cluster.capacity.count).to eq 2 }
    it { expect(cluster.capacity).to include ({node_0: 0}) }
    it { expect(cluster.capacity).to include ({node_1: 1}) }
  end

  describe "::init" do
    let(:settings) do
      {nodes: {
        node_0: {host: "0.0.0.0", port: 1111},
        node_1: {host: "0.0.0.0", port: 1112}
      }}
    end
    before { Pruine.stub(:settings).and_return settings }

    context "when cluster is not prepared" do
      it { expect(cluster.capacity).to be_empty }
    end

    context "when cluster is prepared" do
      before { cluster.init }

      it { expect(cluster.capacity).not_to be_empty }
      it { expect(cluster.capacity[:node_0]).to be_zero }
      it { expect(cluster.capacity[:node_1]).to be_zero }
    end

    context "when cluster was restarted and capacity already exists" do
      before do
        redis.hset(cluster::CAPACITY, :node_0, 20)
        redis.hset(cluster::CAPACITY, :node_1, 1)

        cluster.init
      end

      it { expect(cluster.capacity[:node_0]).to eq 20 }
      it { expect(cluster.capacity[:node_1]).to eq 1 }
    end
  end
end
