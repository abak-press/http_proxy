# coding: utf-8
require "spec_helper"

describe HttpProxy::Trapper do
  let(:trapper) { described_class.clone }

  describe "#trap" do
    let(:hup_handler) { -> { "SIGHUP handler" } }
    let(:int_handler) { -> { "SIGINT handler" } }

    after { trapper.handle("HUP") }
    before do
      trapper.trap("HUP", &hup_handler)
      trapper.trap("INT", &int_handler)
    end

    it { expect(hup_handler).to receive :call }
    it { expect(int_handler).not_to receive :call }
  end
end