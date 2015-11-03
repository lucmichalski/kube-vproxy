var React = require('react');

var NestedComponent2 = React.createClass({
  render: function () {
    return (
      <div ref='ref2'>
        <ul refCollection='refCollection2'>
          <li>1</li>
          <li>2</li>
        </ul>
      </div>
    );
  }
});

var NestedComponent = React.createClass({
  render: function () {
    return (
      <div ref='ref1'>
        <ul refCollection='refCollection1'>
          <li>1</li>
          <li>2</li>
        </ul>
        <NestedComponent2 ref='nested' />
      </div>
    );
  }
});

module.exports = NestedComponent;
