require 'spec_helper'
require 'pincers/core/base_backend'
require 'pincers/core/helpers/form'

describe Pincers::Core::Helpers::Form do

  let!(:backend) do
    be = Class.new(Pincers::Core::BaseBackend).new
    allow(be).to receive(:search_by_xpath)            { |el, sel| el[:childs] }
    allow(be).to receive(:extract_element_tag)        { |el| el[:tag] }
    allow(be).to receive(:extract_element_text)       { |el| el[:text] }
    allow(be).to receive(:extract_element_attribute)  { |el, attribute| el[attribute] }
    be
  end

  let(:el_trigger) do
    {
      tag: 'button',
      name: 'trigger',
      value: 'foo',
      formaction: '/submit/button',
      formmethod: 'post',
      formenctype: 'multipart/form-data',
      formtarget: '_self'
    }
  end

  let(:el_inputs) do
    [
      { tag: 'input', type: 'text', name: 'text', value: 'text value' },
      { tag: 'input', type: 'checkbox', name: 'checked', value: 'on', checked: true },
      { tag: 'input', type: 'checkbox', name: 'not-checked', value: 'on' },
      { tag: 'input', type: 'checkbox', name: 'not-checked', value: 'on' },
      { tag: 'input', type: 'checkbox', name: 'not-checked', value: 'on' },
      { tag: 'button', type: 'button', name: 'just-a-button', value: 'foo' },
      { tag: 'textarea', name: 'textarea', value: 'some text' },
      el_trigger
    ]
  end

  let(:el_form) { { action: '/submit/form', childs: el_inputs } }

  let(:form) { described_class.new backend, el_form }
  let(:form_w_trigger) { described_class.new backend, el_form, el_trigger }

  describe 'action' do
    it { expect(form.action).to eq('/submit/form') }
    it { expect(form_w_trigger.action).to eq('/submit/button') }
  end

  describe 'method' do
    it { expect(form.method).to be :get }
    it { expect(form_w_trigger.method).to be :post }
  end

  describe 'target' do
    it { expect(form.target).to be nil }
    it { expect(form_w_trigger.target).to eq('_self') }
  end

  describe 'encoding' do
    it { expect(form.encoding).to eq 'application/x-www-form-urlencoded' }
    it { expect(form_w_trigger.encoding).to eq 'multipart/form-data' }

    context "when form contains file inputs" do
      before do
        el_inputs << { tag: 'input', type: 'file', name: 'file' }
      end

      it { expect(form.encoding).to eq 'multipart/form-data' }
    end
  end

  describe 'inputs' do
    it { expect(form.inputs).to include ['text', 'text value'] }
    it { expect(form.inputs).to include ['checked', 'on'] }
    it { expect(form.inputs).not_to include ['not-checked', 'on'] }
    it { expect(form.inputs).not_to include ['just-a-button', 'foo'] }
    it { expect(form.inputs).not_to include ['trigger', 'foo'] }
    it { expect(form.inputs).to include ['textarea', 'some text'] }
    it { expect(form_w_trigger.inputs).to include ['trigger', 'foo'] }

    # it { expect(request.url).to eq('http://crabfarm.io/submit') }
    # it { expect(request.method).to eq :post }
    # it { expect(request.headers).to eq({ 'Content-Type' => 'application/x-www-form-urlencoded' }) }
    # it { expect(request.data).to include('text=text+value') }
    # it { expect(request.data).to include('checked=on') }
    # it { expect(request.data).not_to include('not-checked') }
    # it { expect(request.data).to include('selected=second-option') }
    # it { expect(request.data).to include('selected-nv=Third') }
    # it { expect(request.data).not_to include('not-selected') }
    # it { expect(request.data).to include('textarea=textarea+value') }
    # it { expect(request.data).to include('radio=first-radio') }
    # it { expect(request.data).not_to include('button') }
  end

end