require "./spec_helper"

describe Huh do
  it "exposes a semantic version string" do
    Huh::VERSION.should match(/\A\d+\.\d+\.\d+\z/)
  end
end
