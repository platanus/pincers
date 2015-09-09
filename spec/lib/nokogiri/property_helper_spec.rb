require "spec_helper"
require "nokogiri"
require "pincers/nokogiri/property_helper"

describe 'Pincers::Nokogiri::PropertyHelper' do

  let(:form) {
    ::Nokogiri::HTML(%{
      <form method="post" action="/submit">
        <input id="text" type="text" value="text value">
        <input id="checkbox" type="checkbox" value="checkbox value" checked>
        <input id="checkbox-nv" type="checkbox">
        <select id="select">
          <option value="first-option">First</option>
          <option value="second-option" selected>Second</option>
          <option value="third-option">Third</option>
        </select>
        <select id="select-nv">
          <option>First</option>
          <option>Second</option>
          <option selected>Third</option>
        </select>
        <select id="select-ns">
          <option value="first-option">First</option>
          <option value="second-option">Second</option>
          <option value="third-option">Third</option>
        </select>
        <textarea id="textarea">textarea value</textarea>
        <fieldset>
          <input id="radio-1" type="radio" name="radio" value="first-radio" checked>
          <input id="radio-2" type="radio" name="radio" value="second-radio">
          <input id="radio-3" type="radio" name="radio" value="third-radio">
        </fieldset>
      </form>
    }).at_xpath('//form')
  }

  let(:text_input) { helper.new form.at_css('#text') }
  let(:checkbox) { helper.new form.at_css('#checkbox') }
  let(:checkbox_nv) { helper.new form.at_css('#checkbox-nv') }
  let(:select) { helper.new form.at_css('#select') }
  let(:select_nv) { helper.new form.at_css('#select-nv') }
  let(:select_ns) { helper.new form.at_css('#select-ns') }
  let(:textarea) { helper.new form.at_css('#textarea') }
  let(:radio_1) { helper.new form.at_css('#radio-1') }
  let(:radio_2) { helper.new form.at_css('#radio-2') }
  let(:radio_3) { helper.new form.at_css('#radio-3') }

  let(:helper) { Pincers::Nokogiri::PropertyHelper }

  describe "get :value" do
    it { expect(text_input.get(:value)).to eq 'text value' }
    it { expect(checkbox.get(:value)).to eq 'checkbox value' }
    it { expect(checkbox_nv.get(:value)).to eq 'on' }
    it { expect(select.get(:value)).to eq 'second-option' }
    it { expect(select_nv.get(:value)).to eq 'Third' }
    it { expect(select_ns.get(:value)).to be nil }
    it { expect(textarea.get(:value)).to eq 'textarea value' }
    it { expect(radio_1.get(:value)).to eq 'first-radio' }
  end

  describe "get boolean" do
    it { expect(checkbox.get(:checked)).to eq true }
    it { expect(radio_1.get(:checked)).to eq true }
    it { expect(radio_2.get(:checked)).to eq false }
  end

  describe "set" do
    it "should properly handle select elements value" do
      select.set(:value, 'third-option')
      select_nv.set(:value, 'Second')

      expect(select.element.css('option[selected]').first[:value]).to eq('third-option')
      expect(select_nv.element.css('option[selected]').first.content).to eq('Second')
    end

    it "should properly handle textarea element value" do
      textarea.set(:value, 'new textarea value')
      expect(textarea.element.content).to eq('new textarea value')
    end

    it "should properly handle booleans" do
      radio_1.set(:checked, false)
      expect(radio_1.element[:checked]).to be nil
      radio_1.set(:checked, true)
      expect(radio_1.element[:checked]).to eq 'checked'
    end
  end

end
