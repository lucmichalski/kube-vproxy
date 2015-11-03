# react-test-tree [![Build Status](https://travis-ci.org/QubitProducts/react-test-tree.svg)](https://travis-ci.org/QubitProducts/react-test-tree) [![js-semistandard-style](https://img.shields.io/badge/code%20style-semistandard-brightgreen.svg?style=flat-square)](https://github.com/Flet/semistandard)

[![Sauce Test Status](https://saucelabs.com/browser-matrix/oliverwoodings.svg)](https://saucelabs.com/u/oliverwoodings)

## Install

With [npm](http://npmjs.org) do:

```npm install --save-dev react-test-tree```

_Note: This module requires a DOM. If you are not running tests in a browser, consider using_ [jsdom](https://github.com/tmpvar/jsdom)

## Overview

`react-test-tree` is a simple, scalable and concise way of testing React components. It is an evolution of the [react-page-objects](https://github.com/QubitProducts/react-page-objects) library.

A test tree is dev-friendly representation of your entire React component tree, built by recursing through the refs of your elements.

React gives us some great utilities for testing React components, however they lead to overly-verbose boilerplate that clutters your tests. `react-test-tree` tidies this clutter away, allowing you to manipulate your components with short, concise statements:

```jsx
var BozComponent = React.createClass({
  render: function () {
    return (
      <div>
        <button ref="biz">Biz</button>
      </div>
    );
  }
});

var FuzComponent = React.createClass({
  render: function () {
    return <div />
  }
});

var FooComponent = React.createClass({
  render: function () {
    return (
      <div>
        <button ref="bar">Bar</button>
        <select refCollection="baz">
          <option>blue</option>
          <option>gold</option>
        </select>
        <BozComponent ref="boz" />
        <FuzComponent ref="fuz" />
      </div>
    );
  }
});

var fooTree = testTree(<FooComponent />, {
  stub: {
    fuz: null
  }
});
fooTree.bar.click(); // simulates a click
fooTree.boz.biz.click(); // simulates a click
fooTree.baz.length === 2; // collection of nodes
fooTree.fuz === null; // null due to being stubbed out
```

In the above example, `react-test-tree` has recursively built a tree with all refs and refCollections represented as nodes of the tree. Any refs that appear in the `stub` tree config get replaced.


## refs and refCollections

You should be familiar with the `ref` prop in React. They are used when you need to reference an element in your render function. Unfortunately react does not give us an easy way to reference a collection of `ref`s as a whole. `react-test-tree` makes this possible by use of the `refCollection` prop. Declaring `refCollection` on a component will make all it's direct children available on the corresonding tree node as an array:

```jsx
var BarComponent = React.createClass({
  render: function () {
    return (
      <select ref="foo" refCollection="bar">
        <option value="blue">Blue</option>
        <option value="gold">Gold</option>
      </select>;
    );
  }
});

var barTree = testTree(<BarComponent />);
barTree.bar.length === 2;
barTree.bar[0].getAttribute("value") === "blue";
```

__Notes__:
* You can still apply a `ref` as well as a `refCollection` if you want to be able to manipulate the parent element too.
* Your `ref`s and `refCollection`s must not have the same name as any of the public properties of a test node, otherwise they will overwrite them. An error will be thrown if you attempt to do this.


## Stubs

It is inevitable that at some point when testing React components you will want to avoid rendering part of a component. Perhaps it might trigger some sideways data loading, or maybe you want to replace it with a mock. `react-test-tree` allows you to quickly and easily stub out any refs in the tree with either `null` or a replacement component:

```jsx
var MockComponent = React.createClass({
  render: function () {
    console.log(this.props.aProp);
    return <div>{this.props.children}</div>;
  }
});

var BizComponent = React.createClass({
  render: function () {
    return (
      <div>
        <button ref="fuz">Fuz</button>
      </div>
    );
  }
});

var FooComponent = React.createClass({
  render: function () {
    return (
      <div>
        <div ref="bar" />
        <div ref="baz" aProp="hello">Baz</div>
        <div ref="boz" aProp="hello">Boz</div>
      </div>
    );
  }
});

var fooTree = testTree(<FooComponent />, {
  stub: {
    bar: null,
    baz: <MockComponent />
    boz: <MockComponent aProp="foobar">Bazza</MockComponent>,
    biz: {
      fuz: null
    }
  }
});
fooTree.bar; // -> null
fooTree.biz.fuz; // -> null
fooTree.baz; // -> replaced with `MockComponent` and renders `Baz` string as child
fooTree.boz; // -> replaced with `MockComponent` and renders `Bazza` string as child
```

__Notes__:
* You can use any falsy stub value other than `undefined` to completely remove a component (e.g. `null`, `false`).
* The stub object supports nesting; you can stub refs nested deep inside child composite components.
* Mock components are rendered with the new props (and children) of the mock component merged into the original props (and children) of the stubbed ref. This behaviour is demonstrated in the example above; `baz` will log `hello` and have the child `Baz`, whilst `boz` will log `foobar` and have the child `Bazza`.


## Higher Order Components
The HOC pattern is rapidly becoming the most popular successor to mixins (and the [problems associated with them](https://medium.com/@dan_abramov/mixins-are-dead-long-live-higher-order-components-94a0d2f9e750)). Unfortunately every HOC adds another layer into the component tree, making your testing ref chains longer and less explicit. `react-test-tree` can help alleviate this pain by skipping any component that has the `innerComponentRef` property available on its constructor. Here is an example:

```jsx
var InnerComponent = React.createClass({
  render: function () {
    return (
      <div>
        <button ref="span" />
      </div>
    )
  }
});

function withHOC(Component) {
  return React.createClass({
    render: function () {
      return <Component ref="innerComponent" />;
    }
  });
}

var MyComponent = withHOC(InnerComponent);

// Without specifying `innerComponentRef` we have to deal with the HOC in the ref tree
var annoyingTree = testTree(<MyComponent />);
annoyingTree.innerComponent.button.click();

// Adding `innerComponentRef` causes react-test-tree to ignore the HOC, keeping the API nice and clean
MyComponent.innerComponentRef = "innerComponent";
var niceTree = testTree(<MyComponent />);
niceTree.button.click();
```


## API

### `testTree(<Component />, {options})`
Creates the tree and returns the root node, with all `ref` and `refCollection` nodes made available as properties.

*__Options__*
* `stub`: see section on [stubs](#stubs)
* `mount`: if true, the tree's container will be mounted into the body rather than being rendered entirely in memory. Useful if you need to test various styling aspects.
* `context`: use this option to pass through the context object required for your component. test-tree will automatically wrap your component and pass through the context.

### `rootNode.dispose()`
Safely unmount the tree. Will only unmount if component is already mounted. Can only be called on the root node of the tree.

### `node.state`
Returns the state of your component.

### `node.value`
Getter/setter for the element value. Should only be used if the component is a valid HTML element that accepts the value attribute.

### `node.simulate`
Instance of `React.addons.TestUtils.Simulate`, bound to the node. All its methods (beforeInput, blur, change, click, compositionEnd, compositionStart, compositionUpdate, contextMenu, copy, cut, doubleClick, drag, dragEnd, dragEnter, dragExit, dragLeave, dragOver, dragStart, drop, error, focus, input, keyDown, keyPress, keyUp, load, mouseDown, mouseEnter, mouseLeave, mouseMove, mouseOut, mouseOver, mouseUp, paste, reset, scroll, select, submit, touchCancel, touchEnd, touchMove, touchStart, wheel) can be called.

For example, to simulate double-clicking a node called `myButton`, use:

```javascript
myButton.simulate.doubleClick();
```

### `node.click()`
Shorthand method for simulating a click on the node's element.

### `node.getAttribute(attributeName)`
Returns the specified attribute from the node's element.

### `node.getClassName()`
Shorthand method for getting the class attribute of the node's element.

### `node.getProp()`
Returns the specified prop from the node's element.

### `node.isMounted()`
Returns true if the component/element is mounted, false if not.

### `node.getDOMNode()`
Returns the DOM node for the node.

### `node.element`
Reference to the original React element for the node.

### `node.innerText`
Returns the `innerText` of the element (or `textContent` if `innerText` not present).

## Contributing

* `make bootstrap` - install dependencies
* `make test` - run unit tests
* `make build` - build into `dist` folder
* `make lint` - lint the project
* `make test-watch` - run karma with the watch option
* `make release` - increment and publish to npm


## Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally
* Consider starting the commit message with an applicable emoji:
    * :lipstick: `:lipstick:` when improving the format/structure of the code
    * :racehorse: `:racehorse:` when improving performance
    * :non-potable_water: `:non-potable_water:` when plugging memory leaks
    * :memo: `:memo:` when writing docs
    * :penguin: `:penguin:` when fixing something on Linux
    * :apple: `:apple:` when fixing something on Mac OS
    * :checkered_flag: `:checkered_flag:` when fixing something on Windows
    * :bug: `:bug:` when fixing a bug
    * :fire: `:fire:` when removing code or files
    * :green_heart: `:green_heart:` when fixing the CI build
    * :white_check_mark: `:white_check_mark:` when adding tests
    * :lock: `:lock:` when dealing with security
    * :arrow_up: `:arrow_up:` when upgrading dependencies
    * :arrow_down: `:arrow_down:` when downgrading dependencies

(From [atom](https://atom.io/docs/latest/contributing#git-commit-messages))
