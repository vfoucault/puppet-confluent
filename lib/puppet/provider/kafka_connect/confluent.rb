require 'socket'
require 'timeout'

Puppet::Type.type(:kafka_connect).provide(:confluent) do
  initvars

  mk_resource_methods

  def initialize(value={})
    super(value)
    require 'httparty'
    @property_flush = {}
  end

  def self.resturl
    "http://" + Socket.gethostname + ":" + self.get_rest_port
  end

  def self.get_rest_port
    if File.file?("/etc/kafka/connect-distributed.properties")
      rawdata = File.open('/etc/kafka/connect-distributed.properties').readlines().flat_map { |x| x.split("=")[1].strip if x =~ %r{^rest.port(\s)?=} }.compact
      alive = rawdata.map {|x| x if self.port_open?('localhost:' + x)}.compact
      if alive.length > 0
        return alive.sample
      else
        raise Puppet::Error, "Kafka connect is not alive"
      end
    else
      raise Puppet::Error, "Unable to discover rest api port"
    end
  end

  def self.port_open?(uri, seconds=1)
    Timeout::timeout(seconds) do
      begin
        host, port = uri.split(":")
        TCPSocket.new(host, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def get_zk_host
    self.class.get_zk_host
  end

  def resturl
    self.class.resturl
  end

  def self.instances()
    options = [:http_proxyaddr => nil]
    hash_data = Hash.new
    resturi = self.resturl
    connectors = HTTParty.get(resturi + '/connectors', *options).parsed_response
    connectors.each do |connector|
      connector_info = HTTParty.get(resturi + '/connectors/' + connector, *options).parsed_response
      connector_status = HTTParty.get(resturi + '/connectors/' + connector + '/status', *options).parsed_response
      hash_data[connector] = connector_info
      hash_data[connector]['status'] = connector_status['connector']
      hash_data[connector]['tasks'] = connector_status['tasks']
    end

    instances = []
    hash_data.each do |connector, info|
      status = info['status']['state']
      connect = info['config']
      connect.delete('name')
      instances << new(:name    => connector,
                       :ensure  => :present,
                       :connect => connect                      )
    end
    instances
  end

  def self.prefetch(resources)
    topics = instances
    resources.keys.each do |topic|
      if provider = topics.find {|top| top.name == topic}
        resources[topic].provider = provider
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def build_config(resource)
    connect_config = Hash.new
    connect_config['name'] = resource[:name]
    connect_config['config'] = resource[:connect]
    connect_config['config'].delete('name')
    connect_config
  end


  def do_the_job
    resturi = resturl
    case @property_flush[:ensure]
      when :absent
        HTTParty.delete(resturi + '/connectors/' + resource[:name], *options)
      when :present
        config = build_config(resource)
        HTTParty.post(resturi + '/connectors',
                      :body => config.to_json,
                      :headers => {"Content-Type" => "application/json"},
                      :http_proxyaddr => nil)
    end
  end

  def flush
    do_the_job
    @property_hash = self.class.instances()
  end
end