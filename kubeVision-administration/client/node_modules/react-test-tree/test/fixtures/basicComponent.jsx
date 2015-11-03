var React = require('react');

var DumbComponent = React.createClass({
  propTypes: {
    children: React.PropTypes.any
  },

  render: function () {
    return <div>{this.props.children}</div>;
  }
});

var BasicComponent = React.createClass({
  getInitialState: function () {
    return {
      foo: 'bar'
    };
  },
  render: function () {
    return (
      <div {...this.props} ref='foo' className='Foo'>
        <ul refCollection='bar'>
          <li>1</li>
          <li>2</li>
        </ul>
        <input ref='baz' defaultValue='Baz' />
        <div ref='bam'>
          Bam
        </div>
        <DumbComponent refCollection='boz'>
          <div />
          <div />
          <div />
        </DumbComponent>
      </div>
    );
  }
});

module.exports = BasicComponent;
