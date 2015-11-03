var React = require('react');

var InnerComponent = React.createClass({
  render: function () {
    return (
      <div>
        <span ref='innerSpan' />
      </div>
    );
  }
});

var HigherOrderComponent = React.createClass({
  render: function () {
    return (
      <InnerComponent ref='innerComponent' />
    );
  }
});

HigherOrderComponent.innerComponentRef = 'innerComponent';

module.exports = HigherOrderComponent;
