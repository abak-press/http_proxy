require "spec_helper"

describe Pruine::Mapper do
  let(:redis) { MockRedis.new }
  let(:mapper) { described_class.clone }

  before { Pruine.stub(:redis).and_return redis }

  describe "::locate" do
    context "when entry is exists" do
      before { redis.hset mapper::MAP, "entry_0", "node_0" }

      it { expect(mapper.locate("entry_0")).to eq :node_0 }
    end

    context "when entry doesn't exists" do
      it { expect(mapper.locate("entry_0")).to be_nil }
    end
  end

  describe "::attach" do
    context "when entry is exists" do
      before { redis.hset mapper::MAP, "entry_0", "node_0" }

      it { expect(mapper.locate("entry_0")).to eq :node_0 }

      it "should not attach entry to node_0" do
        mapper.attach("entry_0", "node_1")
        expect(mapper.locate("entry_0")).to eq :node_0
      end
    end

    context "when entry doesn't exists" do
      it { expect(mapper.locate("entry_0")).to be_nil }

      it "should attach entry to node_0" do
        mapper.attach("entry_0", "node_0")
        expect(mapper.locate("entry_0")).to eq :node_0
      end
    end
  end
end
