require 'spec_helper'

describe 'Pincers::Chenso::Backend' do

  let!(:pincers) { Pincers.for_chenso }

  before {
    pincers.goto "http://localhost:#{SERVER_PORT}/index.html"
  }

  it_should_properly_read_the_example
  it_should_properly_navigate_through_example
  it_should_properly_enter_data_in_example

end