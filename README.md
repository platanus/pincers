# Pincers

Pincers is jQuery inspired web automation framework with multiple backend support.

## Basic usage

Create a new pincers context object from a webdriver session:

```
pincers = Pincers.for_webdriver driver
```

### Searching

Search for elements matching a given selector, this will return a **pincers object** containg all matching elements.

```
pincers.css('.my-class')
```

**pincers object** are enumerable that yield each contained element wrapped on a **pincers object**.

```
pincers.css('.my-class').map { |s| s.css('.child-class') }
```

**Pincers object** also have a `first` and `last` methods that return the first and last result wrapped on a **pincers object**.

```
pincers.css('.my-class').first.css('.child-class')
```

Searching over a **pincers object** will search among all contained elements children.

```
pincers.css('.my-class').css('.my-child-class')
```

### Single element properties

Retrieve the text contents from the first matching element.

```
pincers.css('.my-class').text
```

Retrieve an attribute from the first matching element:

```
pincers.css('.my-checkbox')[:checked]
```

Retrieve an array with all classes from the first matching element:

```
pincers.css('.my-div').classes
```

Set text on the first matching element:

```
pincers.css('input').fill('sometext')
```

Click on the first matching element:

```
pincers.css('button').click
```

