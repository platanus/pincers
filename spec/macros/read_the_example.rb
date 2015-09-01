module Macros
  def it_should_properly_read_the_example

    describe "css" do
      it { expect(pincers.css('ul.bikes li').count).to eq(3) }
      it { expect(pincers.css('ul.empty').css('li').count).to eq(0) }
    end

    describe "[]" do
      it { expect(pincers.css('p.description').classes).to eq(['history', 'description']) }
    end

    describe "text" do
      it { expect(pincers.text).to include('Lorem ipsum dolor sit amet') }
      it { expect(pincers.css('ul.bikes li').text).to eq('GTMongooseKona') }
    end

    describe "to_html" do
      it { expect(pincers.css('ul.bikes li').to_html).to eq('<li>GT</li><li>Mongoose</li><li>Kona</li>') }
    end

    describe "tag" do
      it { expect(pincers.css('p.description').tag).to eq('p') }
    end

    describe "classes" do
      it { expect(pincers.css('p.description').classes).to eq(['history', 'description']) }
    end

    describe "value" do
      it { expect(pincers.css('#option').value).to be nil }
      it { expect(pincers.css('#other-option').value).to eq 'on' }
    end

    describe "search" do
      it { expect(pincers.search(tag: 'label').first.text).to eq 'Name:' }
      it { expect(pincers.search(content: 'Email').first.tag).to eq 'label' }
      it { expect(pincers.search(content: 'fo').first[:id]).to eq 'option' }
      it { expect(pincers.search(:class => 'empty').first.tag).to eq 'ul' }
      it { expect(pincers.search(:placeholder => 'your').last.tag).to eq 'textarea' }
      it { expect(pincers.search { |b| b.by_attribute(:for, equals: 'option') }.first.tag).to eq 'label' }
      it { expect(pincers.search { |b| b.by_attribute(:value, starts_with: 'Send') }.first.value).to eq 'Send message' }
      it { expect(pincers.search { |b| b.by_attribute(:value, ends_with: 'message') }.first.value).to eq 'Send message' }
    end

    describe "selected" do
      it { expect(pincers.css('#category').selected.first.value).to eq('private') }
    end

    describe "selected?" do
      it { expect(pincers.css('#category option[value=private]').selected?).to be true }
      it { expect(pincers.css('#category option[value=broadcast]').selected?).to be false }
    end

    describe "checked" do
      it { expect(pincers.css('#tags').checked.first.value).to eq('private') }
    end

    describe "checked?" do
      it { expect(pincers.css('#tags input[value=private]').checked?).to be true }
      it { expect(pincers.css('#tags input[value=broadcast]').checked?).to be false }
    end

    describe "input_mode" do
      it { expect(pincers.css('#name').input_mode).to be :text }
      it { expect(pincers.css('#email').input_mode).to be :text }
      it { expect(pincers.css('#message').input_mode).to be :text }
      it { expect(pincers.css('#category').input_mode).to be :select }
      it { expect(pincers.css('#tags input').input_mode).to be :radio }
    end
  end
end