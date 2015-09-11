# Pincers [![Build Status](https://travis-ci.org/platanus/pincers.svg)](https://travis-ci.org/platanus/pincers)

Pincers is a jQuery inspired Ruby DSL on top of webdriver. In other words: an easy to use set of functions that allow you to scrape, automate navigation or test a Javascript intensive webpage.

![pincers diagram](https://cloud.githubusercontent.com/assets/313750/9365154/5ec7213c-4686-11e5-9fbd-7e9b22dae25d.png)

### Example

```ruby
require 'pincers'

Pincers.for_webdriver :firefox do |pincers|
  pincers.goto "google.com"
  pincers.search(tag: 'input', title: 'Search').set("Crabfarm rocks!")
  pincers.search(tag: 'button', type: 'submit').click
  puts pincers.url
end
```

##### Great! But I already know ( selenium | watir | mechanize | nokogiri ) ... why do I need this?

The jQuery interface solves DOM element selection in a very practical way that most programmers feel comfortable with. When using any of the options listed above, we found ourselves missing jQuery's ease of use.

Also, by harnessing the power of nokogiri, pincers lets you extract complex data like tables or lists in a fraction of the time required by using pure webdriver. Take a look at [Read-only Results](#read-only-results).

## Install

To install just run:
```
gem install pincers
```

Or add to your Gemfile and run `bundle install`:
```ruby
gem 'pincers'
```

## Basic usage

Create a new pincers root **context** using your favorite browser:

```ruby
Pincers.for_webdriver :chrome do |pincers|
  # do something, driver object will be discarded at the end of the block.
end
```

You can also pass a webdriver object, or another symbol like `:firefox` or `:phantomjs`.

#### Cleaning up

It is posible to use the `Pincers.for_webdriver` factory method without a block, you will need to manually release the associated resources by calling `close` after you are done:

```ruby
pincers = Pincers.for_webdriver :chrome
# do something
pincers.close # release webdriver resources
```

### Basic Navigation

The first thing to do is to navigate to some url:

```ruby
pincers.goto 'www.crabfarm.io'
```

### Searching

If you have used jQuery before, all this will sound quite familiar to you.

Consider the following HTML structure for the examples below:

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

Most element traversing in pincers is done via [jQuery extended selectors](https://api.jquery.com/category/selectors/) using the `search` method:

```ruby
# Select the second parent by jumping through loops:
pincers.search(".my-class:has(p:contains('Imateapo'))")
```

This call will return another **context** contaning all elements matching the given selector. The **context** object is an enumerable that yields single element **contexts**, so you can use pincers methods on separate elements too:

```ruby
pincers.search('.my-class').map do |div|
  div.search('.child-class') # div is also a contex!
end
```

Pincers **contexts** also have `first` and `last` methods that return the first and last element wrapped on a separate **context**.

```ruby
pincers.search('.my-class').first # first is also a context!
```

Searching over a **context** will search among all contained elements children:

```ruby
parents = pincers.search('.my-class')
parents.search('.child-class') # will select all childs except fourth-child
```

If you don't feel confortable using **css**, pincers also provides a more idiomatic `search` method, it allows you to search by `tag`, `contents`, `class` or any attribute:

```ruby
pincers.search(tag: 'p', class: 'some-class other-class')
pincers.search(tag: 'input', value: 'email@crabfarm.io')
pincers.search(content: 'Title')
```

### Context properties

Retrieve the concatenated text contents for all matched elements.

```ruby
pincers.search('#first-parent').search('.child-class').text # = 'FooBar'
```

Retrieve the concatenated html contents for all matched elements.

```ruby
pincers.search('.child-class').to_html # will dump all p elements in our example.
```

#### First element properties

There are several methods that when called on a **context** will only apply to the first element contained by that context:

Retrieve an attribute from the first matching element:

```ruby
pincers.search('.child-class')[:id] # = 'first-child'
pincers.search('.child-class').attribute('id') # same as above
```

Retrieve the tag name from an element:

```ruby
pincers.search('.child-class').tag # = 'p'
```

Retrieve an array with all classes from the first matching element:

```ruby
pincers.search('.child-class').classes # = ['child-class', 'other-class']
```

### Element interaction

The following methods change the element or document state and are only available in some backends. Like the *Single Element Properties*, when called, these methods only affect the first element in the **context**.

To set the text on a text input

```ruby
pincers.search('input#some-input').set 'sometext'
```

Choose a select box option by it's label

```ruby
pincers.search('select#some-select').set 'Some Label'
```

Choose a select box option by the option text

```ruby
pincers.search('select#some-select').set 'Option text'
```

Or by the option value

```ruby
pincers.search('select#some-select').set by_value: 'option-value'
```

Change a checkbox or radio button state

```ruby
pincers.search('input#some-checkbox').set # check
pincers.search('input#some-checkbox').set false # uncheck
```

Click on a button (or any other element)

```ruby
pincers.search('a#some-link').click
```

Hover over an element

```ruby
pincers.search('div#some-menu').hover
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

#### Read-only results

Using webdriver to extract data that requires iterating over **big lists or lots of table rows** can be painfully slow. To process big datasets pincers provides the `readonly` method, that transforms the webdriver backed result into a nokogiri backed one.

```ruby
list_contents = pincers.search('#long-list').readonly do |list|
  # operating over list is very fast
  list.search('li').map &:text
end
```

#### Navigating frames

Pincers operations can only target one frame at a time. By default, the top frame is selected when location is changed. To switch to a diferent frame use the `goto` method with the `frame:` option:

```ruby
pincers.goto 'http://www.someurlwithfram.es'
pincers.goto frame: pincers.search('#my-frame')
pincers.text # this will return the '#my-frame' frame contents
```

Tip: You can also use a selector directly

```ruby
pincers.goto frame: '#my-frame'
```

To navigate back to the top frame after working on a child frame use the special identifier `:top`:

```ruby
pincers.goto frame: :top
```

#### Waiting for a condition

In javascript enabled backends like webdriver, even though pincers will do it's best to do most of the waiting, it is sometimes necessary to wait for an
special condition before interacting with an element:

```ruby
pincers.search('#my-async-stuff').wait(:enabled)
```

It's posible to wait on the following states:

* `:present`: wait for element to be visible
* `:actionable`: wait for element to be able to receive input
* `:enabled`: wait for input to be enabled
* Any valid DOM property, like `:disabled` or `:value`

Its also possible to wait for custom conditions by passing a block, the process will wait until the block stops returning `false` (only `false`, not `nil`).

```ruby
pincers.search('#my-async-stuff').wait { |r| r.count > 10 }
```

When using a custom condition, you can also wait for the block not to raise a navigation error.

```ruby
pincers.search('#async-button').wait { |r| r.click } # wait until click succeeds
```

By default, the waiting process times out in 10 seconds. This can be changed by setting the `Pincers.config.wait_timeout` property or by calling the search function with the `timeout:` option:

```ruby
pincers.search('#my-async-stuff').wait(:enabled, timeout: 5.0)
```

#### Downloading a resource

You can download resources from the currently loaded document using the `download` method on a **link**, **image** or any other element that has a `src` attribute. **Javascript triggered downloads are not supported by this method**

```ruby
dl = pincers.search('#a-download-link').download
dl.data # the resource data as string
dl.mime # the resource content type
dl.store('/some-file.txt') # store resource in file
```

#### Driver options

Pincers tries its best to configure the webdriver bridge in a way it will fit most use cases. If you need to further configure the driver for a special situation the following options are available when using the `for_webdriver` method:

* `:proxy`: either an url like `www.myproxy.com:40` or a selenium `Proxy` object.
* `:wait_timeout`: default wait timeout for element lookup and any call to `context.wait`
* `:page_timeout`: page load timeout, in ms, defaults to 60 seconds.
* any valid webdriver configuration key

Its also posible to call `for_webdriver` with an already created webdriver object:

```ruby
pincers = Pincers.for_webdriver some_driver_object
```

If this creation method is used, then only the `page_timeout` and `wait_timeout` are options are available.

#### Accessing the underlying backend objects

Sometimes (hopefully not too often) you will need to access the original webdriver or nokogiri api. Pincers provides a couple of methods for you to do so.

To get the document handler itself call `document` on the root context.

```ruby
pincers.document # webdriver driver or nokogiri root node
```

To get the contained nodes on a pincers **context** use `elements`

```ruby
pincers.search('foo').elements # array of webdriver elements or nokogiri nodes.
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/pincers/graphs/contributors)!

<img src="https://cloud.githubusercontent.com/assets/313750/9365675/3409359a-4689-11e5-86b0-3921819c51f8.png" alt="Crabfarm" width="250"/>

Pincers is part of the [Crabfarm Framework](http://crabfarm.io/code).

## License

Pincers is © 2015 [Platanus, spa](http://platan.us). It is free software and may be redistributed under the MIT License terms specified in the [LICENSE](https://raw.githubusercontent.com/platanus/pincers/master/LICENSE.txt) file.
