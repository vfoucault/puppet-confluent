require 'socket'
require 'timeout'

Puppet::Type.type(:kafka_topic).provide(:confluent) do
  # Without initvars commands won't work.
  initvars

  commands :kafka_topics => '/usr/bin/kafka-topics'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  # fetch zkhosts
  def self.get_zk_host
    if File.file?("/etc/kafka/server.properties")
      rawdata = File.open("/etc/kafka/server.properties").readlines().flat_map {|x| x.strip.split('=')[1].split(',') if x.strip.start_with?('zookeeper.connect=')}.compact
      alive = rawdata.map {|x| x if self.port_open?(x)}.compact
      if alive.length > 0
        return alive.sample
      else
        raise Puppet::Error "No zookeeper host alive"
      end
    else
      raise Puppet::Error "Unable to discover zookeeper host"
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

  def self.topics
    kafka_topics('--list', '--zookeeper', get_zk_host).chomp.split("\n")
  end

  def self.instances(name=nil)
    hashdata = Hash.new
    if name
      output = kafka_topics('--describe', '--zookeeper', get_zk_host, '--topic', name).chomp
    else
      output = kafka_topics('--describe', '--zookeeper', get_zk_host).chomp
    end
    output.split('Topic:').map {|x| x.strip if !x.empty?}.compact.each do |entry|
      splitted = entry.split("\t")
      if splitted.length > 1
        if splitted[1].start_with?('PartitionCount:')
          num_partition = splitted[1].split(':')[1]
          replication = splitted[2].split(':')[1]
          hashdata[splitted[0]] = {:name => splitted[0], :num_partitions => Integer(num_partition), :replication_factor => Integer(replication), :partitions => []}
        elsif splitted[1].start_with?('Partition:')
          partition = splitted[1].split()[1]
          leader = splitted[2].split()[1]
          replicats = splitted[3].split()[1]
          insync = splitted[4].split()[1]
          hashstatus = {:partition => partition, :leader => leader, :replicats => replicats, :isr => insync}
          hashdata[splitted[0]][:partitions].push(hashstatus)
        end
      else
        next
      end
    end
    retarray = []
    hashdata.each do |topic, data|
      retarray.push(data)
    end
    instances = []
    retarray.each do |instance|
      instances << new(:name               => instance[:name],
                       :ensure             => :present,
                       :num_partitions     => instance[:num_partitions],
                       :replication_factor => instance[:replication_factor]
      )
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


  def do_the_job
    case @property_flush[:ensure]
      when :absent
        kafka_topics('--delete', '--force', '--topic', resource[:name], '--zookeeper', get_zk_host)
      when :present
        kafka_topics('--create',
                     '--topic', resource[:name],
                     '--zookeeper', get_zk_host,
                     '--partitions', resource[:num_partitions],
                     '--replication-factor', resource[:replication_factor])
    end
  end

  def flush
    do_the_job
    @property_hash = self.class.instances(resource[:name])
  end

end