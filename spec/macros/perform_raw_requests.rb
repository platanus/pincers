module Macros
  def it_should_perform_raw_requests(_merge_support=true)

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

      it "should update the original context content and cookies", skip: !_merge_support do
        pincers.goto("http://localhost:#{SERVER_PORT}/index.html")

        pincers.as_http_client do |client|
          client.get("http://localhost:#{SERVER_PORT}/setcookie?name=sessionid&value=helloworld")
        end

        expect(pincers.text).to eq('Cookie set')
        expect {
          pincers.goto("http://localhost:#{SERVER_PORT}/checkcookie?name=sessionid&value=helloworld")
        }.not_to raise_error
      end
    end

    describe 'replicate' do

      before { pincers.goto("http://localhost:#{SERVER_PORT}/index.html") }

      it "should properly handle links" do
        response = pincers.search('#reference').replicate.fetch
        expect(response.content).to include 'This page is referenced from index'
      end

      it "should properly handle forms" do
        form = pincers.search('form').replicate
        form[:extra] = 'foo'
        response = form.submit

        expect(response.content).to include 'category=private&tag=private&extra=foo'
      end

    end
  end
end
