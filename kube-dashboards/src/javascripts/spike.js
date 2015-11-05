function generateSampleTimeseriesData(length, max) {
  var i, data = [], startTime = new Date().getTime();

  for (i = 0; i < length; i++) {
    data[i] = [startTime + (i * 1000), Math.random() * max];
  }

  return data;
}

function graphTimeseriesData(element, data) {
  var margin, width, height, xScale, xAxis, yScale, yAxis, graph, line, area;

  width = $(element).outerWidth();
  height = $(element).outerHeight();

  xScale = d3.time.scale.utc()
      .range([0, width])
      .domain([data[0][0], data[data.length - 1][0]]);

  xAxis = d3.svg.axis()
      .scale(xScale)
      .ticks(d3.time.seconds, 5)
      .tickSize(-height)
      .orient('bottom');

  yScale = d3.scale.linear()
      .range([height, 0])
      .domain([0, d3.max(data, function (d) { return d[1]; })]);

  yAxis = d3.svg.axis()
      .scale(yScale)
      .tickSize(-width)
      .orient('left');

  line = d3.svg.line()
      .x(function (d) { return xScale(d[0]); })
      .y(function (d) { return yScale(d[1]); });

  area = d3.svg.area()
      .x(function (d) { return xScale(d[0]); })
      .y1(function (d) { return yScale(d[1]); })
      .y0(height);

  graph = d3.select(element)
    .append('svg')
      .attr('class', 'v-graph')
      .attr('width', width)
      .attr('height', height);

  graph.append('g')
      .attr('class', 'v-axis v-axis-x')
      .attr('transform', 'translate(0, ' + height + ')')
      .call(xAxis);

  graph.append('g')
      .attr('class', 'v-axis v-axis-y')
      .call(yAxis);

  graph.append('path')
      .datum(data)
      .attr('class', 'v-data-path')
      .attr('d', line);

  graph.append('path')
      .datum(data)
      .attr('class', 'v-data-area')
      .attr('d', area);
}

graphTimeseriesData('#requests-graph', generateSampleTimeseriesData(60, 100));
graphTimeseriesData('#errors-graph', generateSampleTimeseriesData(60, 20));

// var margin = 20;
// var width = $('.v-graph').outerWidth() - margin;
// var height = $('.v-graph').outerHeight() - margin;

// var totalRequests = [];
// var failedRequests = [];

// for (var i = 0; i < 60; i++) {
//   totalRequests[i] = [i, Math.random() * 50];
//   failedRequests[i] = [i, Math.random() * totalRequests[i][1] * 0.5 ];
// }

// var x = d3.scale.linear()
//   .range([0, width])
//   .domain([0, 59]);

// var y = d3.scale.linear()
//   .range([height, 0])
//   .domain([0, 100]);

// var xAxis = d3.svg.axis()
//   .scale(x)
//   .orient('bottom');

// var yAxis = d3.svg.axis()
//   .scale(y)
//   .orient('left');

// var line = d3.svg.line()
//   .x(function (d) { return x(d[0]); })
//   .y(function (d) { return y(d[1]); });

// var area = d3.svg.area()
//   .x(function (d) { return x(d[0]); })
//   .y1(function (d) { return y(d[1]); })
//   .y0(height);

// var requestsGraph = d3.select('#requests-graph')
//   .append('svg')
//     .attr('width', width + margin)
//     .attr('height', height + margin);

// requestsGraph.append('g')
//   .attr('transform', 'translate(' + margin + ', ' + height + ')')
//   .call(xAxis);

// requestsGraph.append('g')
//   .attr('transform', 'translate(' + margin + ', 0)')
//   .call(yAxis);

// var requestsData = requestsGraph.append('g')
//   .attr('transform', 'translate(' + margin + ', 0)');

// requestsData.append('path')
//   .datum(totalRequests)
//   .attr('class', 'v-line v-line-green')
//   .attr('d', line);

// requestsData.append('path')
//   .datum(totalRequests)
//   .attr('class', 'v-area v-area-green')
//   .attr('d', area);

// extract function for creating graphs

// var errorsGraph = d3.select('#errors-graph')
//   .append('svg')
//     .attr('width', '100%')
//     .attr('height', '100%');

// errorsGraph.append('g').call(xAxis);
// errorsGraph.append('g').call(yAxis);

// var errorsData = errorsGraph.append('g');

// errorsData.append('path')
//   .datum(failedRequests)
//   .attr('class', 'v-line v-line-red')
//   .attr('d', line);

// errorsData.append('path')
//   .datum(failedRequests)
//   .attr('class', 'v-area v-area-red')
//   .attr('d', area);
