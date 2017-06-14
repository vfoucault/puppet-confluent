require 'socket'
require 'timeout'

Puppet::Type.type(:kafka_topic).provide(:confluent) do
  # Without initvars commands won't work.
  initvars

  commands :kafka_topics => '/usr/bin/kafka_topics'

  # fetch zkhosts
  def self.get_zk_host
    if File.file?("/etc/kafka/zookeeper.properties")
      rawdata = File.open("/etc/kafka/server.properties").readlines().flat_map {|x| x.strip.split('=')[1].split(',') if x.strip.start_with?('zookeeper.connect=')}.compact
      alive = rawdata.map {|x| x if port_open?(x)}.compact
      if alive.length > 0
        return alive.sample
      else
        raise Puppet::Error "No zookeeper host alive"
      end
    else
      raise Puppet::Error "Unable to discover zookeeper host"
    end
  end


  def port_open?(uri, seconds=1)
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

  # Optional parameter to run a statement on the MySQL system database.
  def self.describe_topics
    hashdata = Hash.new
    output = kafka_topics('--describe', '--zookeeper', get_zk_host).chomp.split("\n")
    output.split('Topic:').map {|x| x.strip if !x.empty?}.compact.each do |entry|
      splitted = entry.split("\t")
      if splitted.length > 1
        if splitted[1].start_with?('PartitionCount:')
          num_partition = splitted[1].split(':')[1]
          replication = splitted[2].split(':')[1]
          hashdata[splitted[0]] = {:name => splitted[0], :num_partition => num_partition, :replication => replication, :partitions => []}
        elsif splitted[1].start_with?('Partition:')
          # topic1", "Partition: 0", "Leader: 2", "Replicas: 2,1,3", "Isr: 2,1,3"
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
    return retarray
  end

  def self.instances
    self.describe_topics do |instance|
      new(:name => instance[:name],
          :ensure => :present,
          :num_partition => instance[:num_partition],
          :replication_factor => instance[:replication]
      )
    end
  end

  def self.prefetch(resources)
    topics = instances
    resources.keys.each do |topic|
      if provider = topics.find {|db| db.name == topic}
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
    @property_hash = self.class.describe_topic(resource[:name])
  end

end