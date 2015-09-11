require "spec_helper"
require "pincers/css/parser"

describe Pincers::CSS::Parser do

  let(:parser) { described_class }

  describe "is_extended?" do

    it { expect(parser.new('hello:contains(\'world\')').is_extended?).to be true }
    it { expect(parser.new('hello:contains').is_extended?).to be true }
    it { expect(parser.new('hello.contains').is_extended?).to be false }
    it { expect(parser.new('hello:contains-world').is_extended?).to be false }

  end

  describe "to_xpath" do

    it { expect(parser.new('some-tag').to_xpath).to eq ['//some-tag'] }
    it { expect(parser.new('some-tag').to_xpath('.//')).to eq ['.//some-tag'] }

  end

end