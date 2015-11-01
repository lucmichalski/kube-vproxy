var React = require('react');
var Router = require('react-router');
var Route = Router.Route;
var Routes = Router.Routes;
var Redirect = Router.Redirect;
var NotFoundRoute = Router.NotFoundRoute;

var Dashboard = require('./routes/dashboard.jsx');
var Hosts = require('./routes/hosts.jsx');
var Upstreams = require('./routes/upstreams.jsx');
var NotFound = require('./routes/notFound.jsx');

React.renderComponent((
  <Routes location="history">
    <Route name="dashboard" path="/" handler={Dashboard}>
      <Route name="hosts" handler={Hosts} />
      <Route name="upstreams" handler={Upstreams} />
      <Redirect path="/" to="hosts" />
    </Route>
    <NotFoundRoute handler={NotFound} />
  </Routes>
), document.getElementById('dashboard'));

window.React = React;
