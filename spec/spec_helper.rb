# coding: utf-8
$LOAD_PATH.unshift File.expand_path("../../", __FILE__)

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start "root_filter" do
    add_filter "/spec/"
  end

  # Not now
  #SimpleCov.minimum_coverage 95
end

require "http_proxy"

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.formatter = :progress
end
