module Macros
  def it_should_support_jquery_selectors

    describe "search" do
      it { expect(pincers.search('.bikes li:first').count).to eq 1 }
      it { expect(pincers.search('.bikes li:odd').count).to eq 2 }
      it { expect(pincers.search('.bikes li:even').count).to eq 1 }
      it { expect(pincers.search('.bikes li:eq(1)').first.text).to eq 'Mongoose' }
      it { expect(pincers.search('.bikes li:gt(1)').first.text).to eq 'Kona' }
      it { expect(pincers.search('.bikes li:lt(1)').first.text).to eq 'GT' }
      it { expect(pincers.search('.bikes li:contains(\'Kona\')').count).to eq 1 }
      it { expect(pincers.search('input:text')[:id]).to eq 'name' }
      it { expect(pincers.search('input:checkbox')[:id]).to eq 'option' }
      it { expect(pincers.search('input:radio')[:id]).to eq 'first-radio' }
      it { expect(pincers.search('option:selected')[:id]).to eq 'option-2' }
      it { expect(pincers.search('#tags input:checked')[:id]).to eq 'second-radio' }
      it { expect(pincers.search('ul:has(li:contains(\'Trek\'))')[:class]).to eq 'bikes-2' }
    end

  end
end