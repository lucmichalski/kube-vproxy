var React = require('react');
var HigherOrderComponent = require('./higherOrderComponent.jsx');

var StubbingComponent2 = React.createClass({
  render: function () {
    return (
      <div ref='fuz'>
        <button ref='buz'>Buz</button>
      </div>
    );
  }
});

var StubbingComponent = React.createClass({
  render: function () {
    return (
      <div>
        <div ref='nofoo' />
        <div ref='foo' key='foo' bar='bar'>Foo</div>
        <div ref='baz'>Baz</div>
        <StubbingComponent2 ref='boz' />
        <HigherOrderComponent ref='hoc' />
      </div>
    );
  }
});

module.exports = StubbingComponent;
