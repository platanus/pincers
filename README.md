# Pincers

Pincers is a jQuery inspired web automation framework with multiple backend support.

## Backend support:

* webdriver: full
* nokogiri: search and properties only
* nokogiri-on-line: TBA, this will be a nokogiri based implementation with support of some basic navigation features.

## Basic usage

Create a new pincers root **context** from a webdriver session:

```
pincers = Pincers.for_webdriver driver
```

Or from a nokogiri document

```
pincers = Pincers.for_nokogiri document
```

### Basic Navigation

If you are using webdriver, the first thing to do is to navigate to some url:

```ruby
pincers.goto 'www.crabfarm.io'
```

### Searching

Consider the following HTML structure for the examples below

```html
<body>
  <div id="first-parent" class="my-class">
    <p id="first-child" class="child-class other-class">Foo</p>
    <p id="second-child" class="child-class">Bar</p>
  </div>
  <div id="second-parent" class="my-class">
    <p id="third-child" class="child-class">Imateapot</p>
  </div>
  <p id="fourth-child" class="child-class">Imateapot</p>
</body>
```

Search for elements matching a given selector using `css`:

```ruby
pincers.css('.my-class') # will select first-parent and second-parent
```

This will return another **context** contaning all elements matching the given selector. The **context** object is an enumarable that yields single element **contexts**, so you can use pincers methods on separate elements too:

```ruby
pincers.css('.my-class').map do |div|
  div.css('.child-class') # div is also a contex!
end
```

Pincers **contexts** also have `first` and `last` methods that return the first and last element wrapped on a separate **context**.

```ruby
pincers.css('.my-class').first # first is also a context!
```

Searching over a **context** will search among all contained elements children:

```ruby
parents = pincers.css('.my-class')
parents.css('.child-class') # will select all childs except fourth-child
```

### Single element properties

There are several methods that when called on a **context** will only apply to the first element contained by that context:

Retrieve the text contents from the first matching element.

```ruby
pincers.css('.child-class').text # = 'Foo'
```

Retrieve an attribute from the first matching element:

```ruby
pincers.css('.child-class')[:id] # = 'first-child'
```

Retrieve the tag name from an element:

```ruby
pincers.css('.child-class').tag # = 'p'
```

Retrieve an array with all classes from the first matching element:

```ruby
pincers.css('.child-class').classes # = ['child-class', 'other-class']
```

### Element interaction

The following methods change the element or document state and are only available in some backends. Like the *Single Element Properties*, when called, these methods only affect the first element in the **context**.

To set the text on a text input

```ruby
pincers.css('input#some-input').set 'sometext'
```

Choose a select box option by it's label

```ruby
pincers.css('select#some-select').set 'Some Label'
```

Choose a select box option by it's value

```ruby
pincers.css('select#some-select').set 'some-value'
```

Change a checkbox or radio button state

```ruby
pincers.css('input#some-checkbox').set # check
pincers.css('input#some-checkbox').set false # uncheck
```

Click on a button (or any other element)

```ruby
pincers.css('a#some-link').click
```

### Root properties

The root context has some special methods to access document properties.

To get the document title

```ruby
pincers.title
```

To get the document url

```ruby
pincers.url
pincers.uri # same as url but returns an URI object
```

To get the document driver itself (webdriver driver or nokogiri root node)

```ruby
pincers.document
```

### Advanced topics

#### Waiting for a condition

In javascript enabled backends like webdriver, sometimes it's necessary to wait for an element to appear before doing something with it:

```ruby
pincers.css('#my-async-stuff', wait: :present)
```

When using the webdriver backend, it's posible to wait on the following states:

* `:present`: wait for element to show up in the DOM
* `:visible`: wait for element to be visible
* `:enabled`: wait for input to be enabled
* `:not_present`: wait for element to be removed from DOM
* `:not_visible`: wait for element to be hidden

By default, the waiting process times out in 10 seconds. This can be changed by setting the `Pincers.config.wait_timeout` property or by calling the search function with the `timeout:` option:

```ruby
pincers.css('#my-async-stuff', wait: :present, timeout: 5.0)
```

#### Accessing the underlying backend objects

Sometimes (hopefully not too often) you will need to access the original webdriver or nokogiri api. Pincers provides a couple of methods for you to do so.

To get the document handler itself call `document` on the root context.

```ruby
pincers.document # webdriver driver or nokogiri root node
```

To get the contained nodes on a pincers **context** use `elements`

```ruby
pincers.css('.foo').elements # array of webdriver elements or nokogiri nodes.
```
