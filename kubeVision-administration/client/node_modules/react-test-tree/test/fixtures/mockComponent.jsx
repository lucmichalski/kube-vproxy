var React = require('react');

var MockComponent = React.createClass({
  propTypes: {
    children: React.PropTypes.node
  },
  render: function () {
    return <div>{this.props.children}</div>;
  }
});

module.exports = MockComponent;
