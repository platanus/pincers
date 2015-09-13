require 'spec_helper'

describe 'Pincers::Backend::Nokogiri' do

  let!(:example) { ::Nokogiri::HTML File.read "#{FIXTURE_PATH}/index.html" }
  let(:pincers) { Pincers.for_nokogiri example }

  it_should_properly_read_the_example
  it_should_support_jquery_selectors

end