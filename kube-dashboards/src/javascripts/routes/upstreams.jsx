var React = require('react');

var Upstreams = React.createClass({
  render: function () {
    return (
      <div className="v-body">
        <section className="v-overview">
          <div className="container">
            <div className="row v-overview-row">
              <div className="col-md-3">
                <div className="v-statistic">
                  <div className="v-statistic-label">Requests/Sec</div>
                  <div className="v-statistic-value healthy">300.00</div>
                </div>
              </div>
              <div className="col-md-9">
                <div className="v-graph" id="requests-graph"></div>
              </div>
            </div>
            <div className="row v-overview-row">
              <div className="col-md-3">
                <div className="v-statistic">
                  <div className="v-statistic-label">Errors/Sec</div>
                  <div className="v-statistic-value unhealthy">2.00</div>
                </div>
              </div>
              <div className="col-md-9">
                <div className="v-graph" id="errors-graph"></div>
              </div>
            </div>
          </div>
        </section>

        <section className="v-content">
          <div className="container">
            <table className="table">
              <thead>
                <tr>
                  <th>Endpoint</th>
                  <th>Upstream</th>
                  <th className="v-table-value">Requests/Sec</th>
                  <th className="v-table-value">Errors/Sec</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>mailgun.com</td>
                  <td>/app</td>
                  <td className="v-table-value">82.23</td>
                  <td className="v-table-value">0.02</td>
                </tr>
                <tr>
                  <td>mailgun.com</td>
                  <td>/cp</td>
                  <td className="v-table-value">34.23</td>
                  <td className="v-table-value">1.05</td>
                </tr>
                <tr>
                  <td>mailgun.com</td>
                  <td>/proxy</td>
                  <td className="v-table-value">178.23</td>
                  <td className="v-table-value">0.23</td>
                </tr>
                <tr>
                  <td>api.mailgun.com</td>
                  <td>/:domain</td>
                  <td className="v-table-value">56.23</td>
                  <td className="v-table-value">12.01</td>
                </tr>
                <tr>
                  <td>api.mailgun.com</td>
                  <td>/:domain/bounces</td>
                  <td className="v-table-value">49.23</td>
                  <td className="v-table-value">12.01</td>
                </tr>
                <tr>
                  <td>api.mailgun.com</td>
                  <td>/:domain/complaints</td>
                  <td className="v-table-value">92.23</td>
                  <td className="v-table-value">12.01</td>
                </tr>
                <tr>
                  <td>api.mailgun.com</td>
                  <td>/:domain/unsubscribes</td>
                  <td className="v-table-value">100.23</td>
                  <td className="v-table-value">12.01</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    );
  }
});

module.exports = Upstreams;
