require "spec_helper"
require "nokogiri"
require "pincers/nokogiri/wrapper"
require "pincers/chenso/form_helper"

describe 'Pincers::Chenso::FormHelper' do

  let(:simple_form) {
    Pincers::Chenso::FormHelper.new 'http://crabfarm.io', Pincers::Nokogiri::Wrapper.new(Nokogiri::HTML(%{
      <form method="post" action="/submit">
        <input name="text" type="text" value="text value">
        <input name="checked" type="checkbox" checked>
        <input name="not-checked" type="checkbox">
        <select name="selected">
          <option value="first-option">First</option>
          <option value="second-option" selected>Second</option>
          <option value="third-option">Third</option>
        </select>
        <select name="selected-nv">
          <option>First</option>
          <option>Second</option>
          <option selected>Third</option>
        </select>
        <select name="not-selected">
          <option value="first-option">First</option>
          <option value="second-option">Second</option>
          <option value="third-option">Third</option>
        </select>
        <textarea name="textarea">textarea value</textarea>
        <fieldset>
          <input type="radio" name="radio" value="first-radio" checked>
          <input type="radio" name="radio" value="second-radio">
          <input type="radio" name="radio" value="third-radio">
        </fieldset>
        <input type="submit" name="button" value="button value">Submit</textarea>
      </form>
    })).at_xpath('.//form')
  }

  describe "as_request" do

      context "when parsing a siple form" do

        let(:request) { simple_form.submit }

        it { expect(request.url).to eq('http://crabfarm.io/submit') }
        it { expect(request.method).to eq :post }
        it { expect(request.headers).to eq({ 'Content-Type' => 'application/x-www-form-urlencoded' }) }
        it { expect(request.data).to include('text=text+value') }
        it { expect(request.data).to include('checked=on') }
        it { expect(request.data).not_to include('not-checked') }
        it { expect(request.data).to include('selected=second-option') }
        it { expect(request.data).to include('selected-nv=Third') }
        it { expect(request.data).not_to include('not-selected') }
        it { expect(request.data).to include('textarea=textarea+value') }
        it { expect(request.data).to include('radio=first-radio') }
        it { expect(request.data).not_to include('button') }

      end

  end
end
