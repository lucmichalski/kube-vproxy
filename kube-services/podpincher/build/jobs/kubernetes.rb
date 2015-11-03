# encoding: utf-8
require 'kubeclient'
require 'paleta'

class EventProcessor
  def initialize

    ssl_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
    @client = Kubeclient::Client.new ENV.fetch('KUBERNETES_API_URL', 'https://kubernetes:443/api/'), ENV.fetch('KUBERNETES_API_VER', 'v1'), ssl_options: ssl_options

    @colors = {}
  end

  def set_color(metadata, color)

    color_key = metadata['labels']['kubernetes.io/name']
    color_key = metadata['labels']['k8s-app'] if color_key.nil?
    color_key = metadata['labels']['name'] if color_key.nil?
    color_key = metadata['name'] if color_key.nil?

    if @colors[color_key].nil?
      color = metadata['labels']['kubernetes.io/color'].nil? ? "##{color}" : "##{metadata['labels']['kubernetes.io/color']}"
      @colors[color_key] = color
    end

    color_key
  end

  def getHosts
    hosts = {}
    kube_hosts = @client.get_nodes

    palette = Paleta::Palette.generate(:type => :random, :size => kube_hosts.length)

    kube_hosts.each_with_index { |node, index|

      host_status = node[:status]['conditions'].select {|condition| condition['type'] == 'Ready' }

      if host_status[0]['status'] == 'True'
        palette[index].saturation = 20
        hosts[node[:metadata]['name']] = {
          :name => node[:metadata]['name'],
          :friendly_name => node[:metadata]['labels']['kraken-node'],
          :host => node[:metadata]['name'],
          :color => "##{palette[index].hex}"
        }
      end
    }

    hosts
  end

  def getPods
    pods = {}
    kube_pods = @client.get_pods
    palette = Paleta::Palette.generate(:type => :random, :size => kube_pods.length)

    kube_pods.each_with_index { |pod, index|
      pods[pod[:spec]['nodeName']] = [] if pods[pod[:spec]['nodeName']].nil?

      # friendly name
      friendly_name = pod[:metadata]['labels']['kubernetes.io/name']
      friendly_name = pod[:metadata]['labels']['k8s-app'] if friendly_name.nil?
      friendly_name = pod[:metadata]['labels']['name'] if friendly_name.nil?

      # setup color for this pod type
      color_key = set_color(pod[:metadata], palette[index].hex)

      # add the item
      pods[pod[:spec]['nodeName']].push(
        {
          :name => pod[:metadata]['name'],
          :friendly_name => friendly_name,
          :host => pod[:spec]['nodeName'],
          :color => @colors[color_key]
        }
      )

    }

    pods
  end

  def combine(hosts, pods)

    kube_data = {
      :name => 'kraken cluster',
      :color => '#FFFFFF',
      :children => []
    }

    hosts.each do |name, host_data|

      kube_data[:children].push(
        {
          :name => host_data[:name],
          :host => host_data[:name],
          :friendly_name => host_data[:friendly_name],
          :color => host_data[:color],
          :children => pods[host_data[:name]]
        }
      )
    end

    kube_data
  end

  def refresh
    host_info = getHosts()
    pod_info = getPods()
    pod_layout = combine(host_info, pod_info)

    send_event('kubernetes', pod_layout)
  end
end

proc = EventProcessor.new

SCHEDULER.every '5s', :allow_overlapping => false, :first_in => '1s' do |job|
  proc.refresh
end