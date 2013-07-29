require "spec_helper"

describe Pruine::Balancer do
  let(:balancer) { described_class.clone }
  let(:redis) { MockRedis.new }
  let(:settings) do
    {nodes: {
      node_0: {host: "0.0.0.0", port: 1111},
      node_1: {host: "0.0.0.0", port: 1112}
    }}
  end

  before do
    stub_const("Pruine::Cluster", Pruine::Cluster.clone)
    Pruine.stub(:redis).and_return redis
    Pruine.stub(:settings).and_return settings

    redis.hset(Pruine::Mapper::MAP, "entry_0", "node_0")
    redis.hset(Pruine::Cluster::CAPACITY, "node_0", 1)
    redis.hset(Pruine::Cluster::CAPACITY, "node_1", 0)

    Pruine::Mapper.stub(:entry_uid).with("entry_0").and_return "entry_0"
    Pruine::Mapper.stub(:entry_uid).with("entry_1").and_return "entry_1"
  end

  describe "::select" do
    context "when entry is already exists" do
      let(:select) { balancer.select("entry_0") }
      let(:node) { select.first }

      it { expect(node).to eq :node_0 }
    end

    context "when entry doesn't exists" do
      let(:select) { balancer.select("entry_1") }
      let(:node) { select.first }

      it "should attach entry to node" do
        expect(node).to eq :node_1
        expect(Pruine::Cluster.capacity[:node_1]).to eq 1
        expect(Pruine::Mapper.locate("entry_1")).to eq :node_1
      end
    end
  end

  describe "::vacant_node_uid" do
    context "when nodes capacity are different" do
      it { expect(balancer.vacant_node_uid).to eq :node_1 }
    end

    context "when nodes capacity are equal" do
      before { redis.hset(Pruine::Cluster::CAPACITY, "node_1", 1) }

      it { expect(balancer.vacant_node_uid).to eq :node_0 }
    end
  end

  describe "::unless_found" do
    it { expect { |b| balancer.unless_found("entry_0", &b) }.not_to yield_control }
    it { expect { |b| balancer.unless_found("entry_1", &b) }.to yield_control }
  end
end
