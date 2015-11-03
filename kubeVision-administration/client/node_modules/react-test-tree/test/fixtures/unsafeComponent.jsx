var React = require('react');

var UnsafeComponent = React.createClass({
  render: function () {
    return <div ref='value' />;
  }
});

module.exports = UnsafeComponent;
