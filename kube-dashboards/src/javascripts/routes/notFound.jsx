var React = require('react');

var NotFound = React.createClass({
  render: function () {
    return <div></div>;
  },
  componentDidMount: function () {
    console.log('NotFound');
  }
});

module.exports = NotFound;
