module Macros
  module Read
    def it_should_properly_read_the_example

      describe "css" do
        it { expect(pincers.css('ul.bikes li').count).to eq(3) }
        it { expect(pincers.css('ul.empty').css('li').count).to eq(0) }
      end

      describe "[]" do
        it { expect(pincers.css('p.description').classes).to eq(['history', 'description']) }
      end

      describe "text" do
        it { expect(pincers.css('ul.bikes li').text).to eq('GT') }
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

      describe "selected" do
        it { expect(pincers.css('#category').selected.value).to eq('private') }
      end

      describe "selected?" do
        it { expect(pincers.css('#category option[value=private]').selected?).to be true }
        it { expect(pincers.css('#category option[value=broadcast]').selected?).to be false }
      end

      describe "checked" do
        it { expect(pincers.css('#tags').checked.value).to eq('private') }
      end

      describe "checked?" do
        it { expect(pincers.css('#tags input[value=private]').checked?).to be true }
        it { expect(pincers.css('#tags input[value=broadcast]').checked?).to be false }
      end
    end
  end
end