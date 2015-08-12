require 'spec_helper'
require 'nokogiri'

describe 'Pincers::Backend::Nokogiri' do

  let!(:example) { ::Nokogiri::HTML File.read "#{FIXTURE_PATH}/index.html" }
  let(:pincers) { Pincers.for_nokogiri example }

  it_should_properly_read_the_example

end