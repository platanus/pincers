module Macros
  def it_should_properly_handle_frames_in_example

    describe "goto" do
      it "should switch to selected frame when called on a search context" do
        pincers.search('#the-frame').goto
        expect(pincers.text).to include('This is the frame content')
      end

      it "should switch to desired frame when called with frame: id" do
        pincers.goto frame: '#the-frame'
        expect(pincers.text).to include('This is the frame content')
      end

      context "when inside a child frame" do
        before { pincers.search('#the-frame').goto }

        it "should switch to top frame when called with frame: :top" do
          pincers.goto frame: :top
          expect(pincers.text).to include('This is the main page')
        end

        it "should load frames with no target in same frame" do
          pincers.search('#self').click
          expect(pincers.text).to include('This page is referenced from index')
          pincers.goto frame: :top
          expect(pincers.text).to include('This is the main page')
        end

        it "should load frames with target: _top in top frame" do
          pincers.search('#top').click
          pincers.goto frame: :top
          expect(pincers.text).to include('This page is referenced from index')
        end

      end
    end
  end
end