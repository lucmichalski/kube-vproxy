import logging
import gevent
import pprint
import os
import json
import flask
import jinja2
import time
from gevent.queue import Queue
from gevent.threadpool import ThreadPool
from locust import HttpLocust, TaskSet, task, events, web
from flask import Flask, Response, render_template, send_from_directory, send_file
from influxdb.influxdb08 import InfluxDBClient

influx_queue = Queue()
dashboard_queue = Queue(1000)
project_root = os.path.dirname(os.path.abspath(__file__))
web.app.jinja_loader = jinja2.ChoiceLoader([
    jinja2.FileSystemLoader(os.path.join(project_root, 'templates')),
    web.app.jinja_loader,
])

def influx_worker():
  """The worker pops each item off the queue and sends it to influxdb."""
  host = os.getenv('INFLUXDB_HOST', 'influxdb')
  port = int(os.getenv('INFLUXDB_PORT', '8086'))
  user = os.getenv('INFLUXDB_USER', 'root')
  pw = os.getenv('INFLUXDB_PASSWORD', 'root')
  name = os.getenv('INFLUXDB_NAME', 'k8s')
  influx_client = InfluxDBClient (host, port, user, pw, name)
  while True:
    data = influx_queue.get()
    name = data['name']
    receipt_time = data.pop('received_time')

    write_to_influx(influx_client, data)

    data['time'] = receipt_time
    data['name'] = name + ".received"
    write_to_influx(influx_client, data)

    data['time'] = int(time.time())
    data['name'] = name + ".written"
    write_to_influx(influx_client, data)

def write_to_influx(influx_client, data):
  data = dict(data)
  name = data.pop('name')
  columns = sorted(data.keys())
  points = map(data.get, columns)
  json_body = [{ "name": name, "columns": columns, "points": [points] }]
  logging.info('Writing %s', json_body)
  influx_client.write_points (json_body)

def get_requests_per_second(stat, client_id):
  request = stat['method'] + stat['name'].replace('/', '-')
  request_key = "locust.{0}.reqs_per_sec.{1}".format(request, client_id)

  for epoch_time, count in stat['num_reqs_per_sec'].items():
    now = int(time.time())
    influx_queue.put({
      'name': 'trogdor_rps',
      'value': count,
      'time': epoch_time, 
      'request_key': request_key,
      'received_time': now
    })

    # drop things on the floor and run away, laughing maniacally 
    if dashboard_queue.full():
      return

    dashboard_queue.put({
      'type': 'rps',
      'request_key': request_key,
      'value': count
    })

def get_response_time(stat, client_id):
  request = stat['method'] + stat['name'].replace('/', '-')

  request_key = "locust.{0}.response_time.{1}".format(request, client_id)
  epoch_time = int(stat['start_time'])

  # flatten a dictionary of {time: count} to [time, time, time, ...]
  response_times = []
  for t, count in stat['response_times'].iteritems():
    for _ in xrange(count):
      response_times.append(t)

  # XXX: try averaging down to reduce write load to influx
  response_times = [ float(stat['total_response_time']) / stat['num_requests'] ]

  for response_time in response_times:
    now = int(time.time())
    influx_queue.put({
      'name': 'trogdor_rts',
      'value': response_time,
      'time': epoch_time,
      'request_key': request_key,
      'received_time': now
    })

    # drop things on the floor and run away, laughing maniacally 
    if dashboard_queue.full():
      continue

    dashboard_queue.put({
      'type': 'art',
      'request_key': request_key,
      'value': count
    })

def slave_report_log (client_id, data, ** kw):
  for stat in data['stats']:
    get_response_time(stat, client_id)
    get_requests_per_second(stat, client_id)

class JsonSerialization(TaskSet):
  @task(1)
  def json(self):
    with self.client.get("/json", catch_response=True) as response:
      logging.debug('Response headers:')
      logging.debug(pprint.pformat(response.headers, 2))
      logging.debug('Response content:')
      logging.debug(response.content)    

class WebsiteUser(HttpLocust):
  task_set = JsonSerialization

# Server sent events
class ServerSentEvent:
    FIELDS = ('event', 'data', 'id')
    def __init__(self, data, event=None, event_id=None):
        self.data = data
        self.event = event 
        self.id = event_id 

    def encode(self):
        if not self.data:
            return ""
        ret = []
        for field in self.FIELDS:
            entry = getattr(self, field) 
            if entry is not None:
                ret.extend(["%s: %s" % (field, line) for line in entry.split("\n")])
        return "\n".join(ret) + "\n\n"

@web.app.route("/dashboard")
def my_dashboard():
    return render_template('dashboard.html')

@web.app.route("/files/<path:path>")
def send_js(path):
    return send_file(project_root + '/files/' + path)

@web.app.route("/stream")
def stream():
    def gen():
        while True:
            if dashboard_queue.empty():
              time.sleep(0.05)
              continue
            queue_data = dashboard_queue.get()
            data = json.dumps({"type": queue_data['type'], "slave_id": queue_data['request_key'], 'val': queue_data['value']})
            ev = ServerSentEvent(data)
            yield ev.encode()
            time.sleep(0.05)

    return Response(gen(), mimetype="text/event-stream")

events.slave_report += slave_report_log
gevent.spawn(influx_worker)
