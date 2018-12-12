require 'spec_helper'

describe 'Pincers::Core::RootContext' do

  let!(:backend) do
    be = double('Pincers::Core::BaseBackend')
    allow(be).to receive(:javascript_enabled?)        { true }
    allow(be).to receive(:document)                   { 'not a real document' }
    allow(be).to receive(:document_root)              { ['root_element'] }
    allow(be).to receive(:document_url)               { 'http://the.page.url' }
    allow(be).to receive(:document_title)             { 'The page title' }
    allow(be).to receive(:fetch_cookies)              { [{ name: 'FakeCookie' }] }
    allow(be).to receive(:navigate_to)
    allow(be).to receive(:navigate_forward)
    allow(be).to receive(:navigate_back)
    allow(be).to receive(:refresh_document)
    allow(be).to receive(:close_document)
    allow(be).to receive(:search_by_css)              { |el, sel| ['child_element_1', 'child_element_2'] }
    allow(be).to receive(:search_by_xpath)            { |el, sel| ['child_element_1', 'child_element_2'] }
    allow(be).to receive(:extract_element_tag)        { |el| "#{el.upcase}-NAME" }
    allow(be).to receive(:extract_element_text)       { |el| "#{el} text" }
    allow(be).to receive(:extract_element_html)       { |el| "<div>#{el} html</div>" }
    allow(be).to receive(:extract_element_attribute)  { |el, attribute| "#{el} #{attribute}" }
    allow(be).to receive(:element_is_actionable?)     { true }
    allow(be).to receive(:set_element_text)
    allow(be).to receive(:click_on_element)
    allow(be).to receive(:double_click_on_element)
    allow(be).to receive(:right_click_on_element)
    allow(be).to receive(:hover_over_element)
    allow(be).to receive(:drag_and_drop)
    allow(be).to receive(:switch_to_frame)
    allow(be).to receive(:switch_to_top_frame)
    allow(be).to receive(:switch_to_parent_frame)

    be
  end

  let(:pincers) { Pincers::Core::RootContext.new backend }

  describe "url" do
    it "should return the current url" do
      expect(pincers.url).to eq('http://the.page.url')
    end
  end

  describe "uri" do
    it "should return the current url as an uri" do
      expect(pincers.uri).to be_a(URI)
    end
  end

  describe "title" do
    it "should return the current page title" do
      expect(pincers.title).to eq('The page title')
    end
  end

  describe "goto" do
    it "should call navigate_to and return self" do
      expect(pincers.goto 'http://foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_to).with('http://foo.bar')
    end

    it "should call switch_to_frame with proper element if called with frame: context" do
      pincers.goto frame: pincers.search('#frame')
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end

    it "should call switch_to_frame with proper element if called with frame: selector" do
      pincers.goto frame: '#foo.bar'
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end

    it "should call switch_to_top_frame if called with frame: :top" do
      pincers.goto frame: :top
      expect(backend).to have_received(:switch_to_top_frame)
    end

    it "should call switch_to_parent_frame if called with frame: :parent" do
      pincers.goto frame: :parent
      expect(backend).to have_received(:switch_to_parent_frame)
    end

    it "should fail when called with invalid options" do
      expect { pincers.goto }.to raise_error(ArgumentError)
      expect { pincers.goto frame: :disneyland }.to raise_error(Pincers::BackendError)
      expect { pincers.goto cuadro: 'cangrejo' }.to raise_error(Pincers::BackendError)
    end

    it "when called on a frame element context it should call goto frame: context on the root context" do
      pincers.search('#frame').goto
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end
  end

  describe "back" do
    it "should call navigate_back and return self" do
      expect(pincers.back 'foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_back).with('foo.bar')
    end
  end

  describe "forward" do
    it "should call navigate_forward and return self" do
      expect(pincers.forward 'foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_forward).with('foo.bar')
    end
  end

  describe "close" do
    it "should call close_document and return self" do
      expect(pincers.close).to eq(pincers)
      expect(backend).to have_received(:close_document)
    end
  end

  describe "classes" do
    it "should return every element class as an array" do
      expect(pincers.classes).to eq(['root_element', 'class'])
    end
  end

  describe "tag" do
    it "should return the downcased tag name from the first of matched elements" do
      expect(pincers.tag).to eq('root_element-name')
    end
  end

  describe "text" do
    it "should return the text from the first of matched elements" do
      expect(pincers.text).to eq('root_element text')
    end
  end

  describe "search" do
    it "should load a new child context that applies the given query" do
      childs = pincers.search('selector')
      expect(childs.query.lang).to eq :css
      expect(childs.query.query).to eq 'selector'
      expect(childs.query.limit).to be nil

      childs = pincers.search('selector', limit: 1)
      expect(childs.query.limit).to be 1
    end

    it "should use xpath for pseudo classes or explicit xpath" do
      childs = pincers.search(xpath: 'selector')
      expect(childs.query.lang).to eq :xpath
      expect(childs.query.query).to eq 'selector'

      childs = pincers.search('li:eq(1)')
      expect(childs.query.lang).to eq :xpath
      expect(childs.query.query).to eq './/li[(position()-1)=1]'
    end

    context "when in advanced mode" do

      before { allow(pincers).to receive(:advanced_mode?) { true } }

      it "should automatically invoke the backend.search_by_css method" do
        pincers.search('selector')
        expect(backend).to have_received(:search_by_css).exactly(1).times
      end
    end
  end

  describe "reload" do
    it "should repeat the search result's query" do
      pincers.search('selector').reload.reload
      expect(backend).to have_received(:search_by_css).exactly(2).times
    end

    it "should fail for frozen sets" do
      expect { pincers.search('selector')[1].reload }.to raise_error Pincers::FrozenSetError
    end

    context "when parent hasnt been loaded yet" do

      let!(:parents) { pincers.search('selector') }

      it "should trigger reload on parent" do
        parents.search('other').reload
        expect(backend).to have_received(:search_by_css).exactly(3).times # 1 for parent and 1 for each of the 2 childs
      end
    end
  end

  describe "to_html" do
    it "should return the html representation of the matched elements" do
      expect(pincers.to_html).to eq('<div>root_element html</div>')
    end
  end

  describe "wait" do
    it "should wait for block to return true" do
      start = Time.now
      expect { pincers.wait(timeout: 1.0) { Time.now - start > 5 } }.to raise_error Pincers::ConditionTimeoutError
      expect { pincers.wait(timeout: 1.0) { Time.now - start > 0 } }.not_to raise_error
    end

    it "should wait for block not to raise NavigationErrors" do
      expect { pincers.wait(timeout: 1.0) { raise ArgumentError.new }.to raise_error ArgumentError }
      start = Time.now
      expect { pincers.wait(timeout: 1.0) { raise Pincers::NavigationError.new(nil, nil) if Time.now - start < 5 } }.to raise_error Pincers::ConditionTimeoutError
      start = Time.now
      expect { pincers.wait(timeout: 2.0) { raise Pincers::NavigationError.new(nil, nil) if Time.now - start < 1 } }.not_to raise_error
    end
  end

  describe "readonly" do
    it "should return a new context with access to the provided elements" do
      original = pincers.search('selector')
      original.readonly do |context|
        expect(context.count).to eq original.count
        expect(context.tag).to eq 'div'
        expect(context.first.text).to eq 'child_element_1 html'
        expect(context.last.text).to eq 'child_element_2 html'
      end
    end
  end

  # Test simple input methods

  [
    { name: :set_text, mapped_to: :set_element_text, args: ['foo'], expected_args: [ 'root_element', 'foo' ] },
    { name: :click, mapped_to: :click_on_element, expected_args: [ 'root_element', [] ] },
    { name: :click, mapped_to: :click_on_element, args: ['modifier'], expected_args: [ 'root_element', ['modifier'] ] },
    { name: :right_click, mapped_to: :right_click_on_element },
    { name: :double_click, mapped_to: :double_click_on_element },
    { name: :hover, mapped_to: :hover_over_element }
  ]
  .each do |method|
    describe method[:name] do
      it "should map to backend.#{method[:mapped_to]}" do
        expect(pincers.send *([method[:name]] + (method[:args] || []))).to eq pincers
        expect(backend).to have_received(method[:mapped_to]).with(*(method[:expected_args] || ['root_element']))
      end
    end
  end

  describe "drag_to" do
    it "should map to backend.drag_and_drop" do
      pincers.search('sel').first.drag_to pincers.search('sel').last
      expect(backend).to have_received(:drag_and_drop).with('child_element_1', 'child_element_2')
    end
  end

  context "given an unloaded search result" do

    let(:search) { pincers.search('selector') }

    describe "element" do
      it "should trigger elements to be loaded with limit: 1 and return first element" do
        search.element
        expect(backend).to have_received(:search_by_css).with('root_element', 'selector', 1)
      end

      context "after calling elements" do

        before { search.elements }

        it "should not trigger an elements reloading" do
          search.element
          expect(backend).to have_received(:search_by_css).exactly(1).times
        end
      end
    end

    describe "element!" do
      it "should trigger elements to be loaded with limit: 1 and return first element" do
        search.element!
        expect(backend).to have_received(:search_by_css).exactly(1).times
        expect(backend).to have_received(:search_by_css).with('root_element', 'selector', 1)
      end
    end

    describe "elements" do
      it "should trigger elements to be loaded with original limit and return all elements" do
        search.elements
        expect(backend).to have_received(:search_by_css).with('root_element', 'selector', nil)
      end

      context "after calling element" do

        before { search.element }

        it "should trigger element to be reloaded with origin limit" do
          expect(backend).to have_received(:search_by_css).with('root_element', 'selector', 1)
          search.elements
          expect(backend).to have_received(:search_by_css).with('root_element', 'selector', nil)
        end
      end
    end

    describe "is Enumerable" do
      it "should iterate over matching elements, wrapping each element in a new context" do
        expect(search.to_a.count).to eq(2)
        expect(search).to all ( be_a Pincers::Core::SearchContext )
      end
    end

    describe "attribute" do

      it "should return the required attribute for the first element" do
        expect(search.attribute(:type)).to eq('child_element_1 type')
      end

    end

    describe "[]" do

      it "should return the element in position N wrapped in search context if numeric index is given" do
        expect(search[1]).to be_a(Pincers::Core::SearchContext)
        expect(search[1].element!).to eq('child_element_2')
      end

      it "should return the attribute named N of the first element if string is given" do
        expect(search[:type]).to eq('child_element_1 type')
      end

    end

    describe "to_html" do
      it "should concatenate the html representation of all matched elements" do
        expect(search.to_html).to eq('<div>child_element_1 html</div><div>child_element_2 html</div>')
      end
    end

  end

end