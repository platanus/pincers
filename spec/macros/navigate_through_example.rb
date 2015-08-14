module Macros
  def it_should_properly_navigate_through_example

    describe 'goto' do
      it "should switch to the provided url" do
        pincers.goto("http://localhost:#{SERVER_PORT}/frame.html")
        expect(pincers.text).to include('This is the frame content')
      end
    end

  end
end