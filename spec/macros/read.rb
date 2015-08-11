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

      describe "classes" do
        it { expect(pincers.css('p.description').classes).to eq(['history', 'description']) }
      end

      describe "text" do
        it { expect(pincers.css('ul.bikes li').text).to eq('GT') }
      end

      describe "to_html" do
        it { expect(pincers.css('ul.bikes li').to_html).to eq('<li>GT</li><li>Mongoose</li><li>Kona</li>') }
      end
    end
  end
end