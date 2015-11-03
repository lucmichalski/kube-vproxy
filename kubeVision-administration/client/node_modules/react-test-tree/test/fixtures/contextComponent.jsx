var React = require('react');

var ContextComponent = React.createClass({
  contextTypes: {
    foo: React.PropTypes.string,
    bar: React.PropTypes.number
  },
  render: function () {
    return null;
  }
});

module.exports = ContextComponent;
