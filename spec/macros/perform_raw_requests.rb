module Macros
  def it_should_perform_raw_requests

    describe 'download' do
      it "should retrieve the resouce pointed by the element" do
        expect(pincers.search('#download').download.content).to eq 'Some text'
      end

      it "should fail if element does not point to a resource" do
        expect { pincers.search('label').download }.to raise_error Pincers::NavigationError
      end
    end

    describe 'as_http_client' do
      it "should send raw requests using cookies set by browser requests" do
        pincers.goto("http://localhost:#{SERVER_PORT}/setcookie?name=sessionid&value=helloworld")
        expect {
          pincers.as_http_client.get("http://localhost:#{SERVER_PORT}/checkcookie?name=sessionid&value=helloworld")
        }.not_to raise_error
      end

      it "should support relative urls" do
        pincers.goto("http://localhost:#{SERVER_PORT}/index.html")

        expect {
          pincers.as_http_client.get("/resource.txt")
        }.not_to raise_error
      end
    end

  end
end