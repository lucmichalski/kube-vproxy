#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'net/http'
require 'uri'
require 'json'

options = {}
@parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options]"
  opts.on(:REQUIRED, "-tTARGETS", "--targets TARGETS", "targets") do |t|
    options[:targets] = t.split(',')
  end
  opts.on(:REQUIRED, "-dDIRECTORY", "--directory DIRECTORY", "directory") do |d|
    options[:directory] = d
  end
  opts.on("-K", "--[no-]kubelet-discover", "Enable kubelet discovery") do |v|
    options[:kubelet] = v
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
@parser.parse!

def print_usage
  puts @parser.help
  exit
end

if options[:directory].nil? || options[:targets].nil?
  print_usage
end

def build_config(targets, kubelet_discovery=false)
  config = {
    'global' => {
      'scrape_interval' => '10s',
      'evaluation_interval' => '10s'
    },
    'scrape_configs' => targets.map do |target|
      address_var = "#{target}_TARGET_ADDRESS"
      host_port_vars = ["#{target}_SERVICE_HOST", "#{target}_SERIVCE_PORT"]
      target_address = ENV[address_var]
      target_address ||= host_port_vars.map {|x| ENV[x]}.join(':') if host_port_vars.all?{|x| ENV.has_key?(x)}
      raise ArgumentError.new("one of \"#{address_var}\" or #{host_port_vars} must exist in ENV") if target_address.nil?
      {
        'job_name' => target,
        'target_groups' => [{ 'targets' => [target_address] }]
      }
    end
  }
  # XXX: quick hack that assumes use of kubectl-proxy
  if kubelet_discovery
    kube_api_server = ENV.fetch('KUBE_APISERVER_TARGET_ADDRESS', 'localhost:8001')
    kubelet_port = ENV.fetch('KUBELET_PORT', '10255')
    nodes_json = JSON.parse(Net::HTTP.get_response(URI.parse("http://#{kube_api_server}/api/v1/nodes")).body)
    kubelet_node_names = nodes_json['items'].map {|x| x['metadata']['name'] }
    config['scrape_configs'] << {
      'job_name' => 'KUBELETS',
      'target_groups' => [{
        'targets' => kubelet_node_names.map { |name| "#{name}:#{kubelet_port}" }
      }]
    }
  end
  config
end

puts '------------------'
puts "Using #{options[:directory]} as the root for prometheus configs and data."
system("mkdir -p #{options[:directory]}")
options[:config]="#{options[:directory]}/prometheus.yaml"
options[:storage]="#{options[:directory]}/storage"
options[:level]="debug"

puts '-------------------'
puts 'Starting Prometheus with:'
puts "targets: #{options[:targets]}"
puts "config: #{options[:config]}"
puts "storage: #{options[:storage]}"

puts 'config file:'
config_struct = build_config(options[:targets], options[:kubelet])
config_yaml = config_struct.to_yaml
puts config_yaml
IO.write(options[:config], config_yaml)

puts '-------------------'
exec(
  '/bin/prometheus',
  "-log.level=#{options[:level]}",
  "-config.file=#{options[:config]}",
  "-storage.local.path=#{options[:storage]}",
  '-web.console.libraries=/go/src/github.com/prometheus/prometheus/console_libraries',
  '-web.console.templates=/go/src/github.com/prometheus/prometheus/consoles'
)
