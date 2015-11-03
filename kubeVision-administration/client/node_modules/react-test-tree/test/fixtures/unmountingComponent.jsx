var React = require('react');

var UnmountingComponent = React.createClass({

  getInitialState: function () {
    return {
      mounted: true
    };
  },

  setUnmounted: function () {
    this.setState({
      mounted: false
    });
  },

  render: function () {
    return (
      <div>
        <ul refCollection='foo'>
          <li>1</li>
          {this.renderIfMounted(<li>2</li>)}
        </ul>
        {this.renderIfMounted(
          <div ref='bar'>
            <ul refCollection='baz'>
              <li>1</li>
              <li>2</li>
            </ul>
          </div>
        )}
      </div>
    );
  },

  renderIfMounted: function (children) {
    if (this.state.mounted) {
      return children;
    }
  }

});

module.exports = UnmountingComponent;
