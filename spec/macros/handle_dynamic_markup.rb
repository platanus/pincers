module Macros
  def it_should_properly_handle_dynamic_markup

    context "when navigating dynamic content" do

      before { pincers.goto "http://localhost:#{SERVER_PORT}/dynamic.html" }

      describe "wait(:present)" do
        it "should wait for content to be present" do
          expect { pincers.css('#half-second-content').wait(:present, timeout: 1.0) }.not_to raise_error
        end

        it "should timeout if content is not present on time" do
          expect { pincers.css('#five-second-content').wait(:present, timeout: 1.0) }.to raise_error Pincers::ConditionTimeoutError
        end
      end

      describe "hover" do

        it "should properly activate hover-able items" do
          expect(pincers.css('#hover-container').text).to eq ''
          pincers.css('button#hover').hover
          expect(pincers.css('#hover-container').text).to eq 'hover content'
          pincers.css('#hover-container').hover
          expect(pincers.css('#hover-container').text).to eq ''
        end

      end

    end

  end
end