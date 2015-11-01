var React = require('react');
var Router = require('react-router');
var ActiveState = Router.ActiveState;
var Link = Router.Link;

function getActiveRoute() {
  if (Dashboard.isActive('hosts')) {
    return 'hosts';
  } else if (Dashboard.isActive('upstreams')) {
    return 'upstreams';
  }
}

function getPlaceholder() {
  if (Dashboard.isActive('hosts')) {
    return 'Search hosts and locations...';
  } else if (Dashboard.isActive('upstreams')) {
    return 'Search upstreams and endpoints...';
  };
}

function willOpenNewWindow(e) {
  return e.button !== 0 || !!(e.metaKey || e.altKey || e.ctrlKey || e.shiftKey);
}

var Dashboard = React.createClass({
  mixins: [ActiveState],
  getInitialState: function () {
    return {};
  },
  updateActiveState: function () {
    this.setState({
      placeholder: getPlaceholder(),
      search: this.props.query.search || ''
    });
  },
  render: function () {
    return (
      <div className="v-wrapper">
        <nav className="v-header">
          <div className="container">
            <Link to="dashboard" className="v-header-brand">LOGO</Link>
            <ul className="v-header-nav">
              <li><Link to="hosts">Hosts</Link></li>
              <li><Link to="upstreams">Upstreams</Link></li>
            </ul>
            <form className="v-header-search">
              <input type="search" name="search" placeholder={this.state.placeholder} value={this.state.search} onChange={this.handleChange} />
              <button type="submit" onClick={this.handleSubmit}><i className="fa fa-search"></i></button>
            </form>
          </div>
        </nav>
        <this.props.activeRouteHandler />
      </div>
    );
  },
  handleChange: function (e) {
    this.setState({ search: e.target.value });
  },
  handleSubmit: function (e) {
    if (willOpenNewWindow(e)) {
      return;
    }

    e.preventDefault();
    Router.transitionTo(getActiveRoute(), {}, { search: this.state.search });
  }
});

module.exports = Dashboard;
