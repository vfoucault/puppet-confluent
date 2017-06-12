Puppet::Type.type(:kafka_topic).provide(:confluent) do

  has_feature :manage_topics
  commands :kafka_topics => '/usr/bin/kafka-topics'

  mk_resource_methods

  @@topics_classvars = {
      :zk_host => "",
      :topics => "",
      :initialized => false,
  }

  def initialize(value={})
    super(value)
    @property_flush = {}
    if not @@topics_classvars[:initialized] then
      output = `grep -E '(server.1|clientPort)' /etc/kafka/zookeeper.properties`.chomp.split("\n")
      zk_info = output.map { |x| x.split('=')}.map { |x| { x[0].strip.gsub('.','').to_sym => x[1].strip.gsub(%r{:\d*},'') }}.reduce Hash.new, :merge
      ignored_topics = %w[__confluent.support.metrics _schemas]
      @@topics_classvars[:zk_host] = zk_info[:server1] + ':' + zk_info[:clientPort]
      topics = kafka_topics('--list', '--zookeeper', @@topics_classvars[:zk_host]).chomp.split("\n")
      @@topics_classvars[:topics] = topics - ignored_topics
      @@topics_classvars[:initialized] = true
    end
  end

  TOPIC_REGEX = %r{Topic:(?'topicname'[\S]*).*PartitionCount:(?'numpartition'\d{1,2}).*ReplicationFactor:(?'rep_factor'\d{1,2})}

  def self.describe_topic(name)
    output = kafka_topics('--describe', '--topic', name, '--zookeeper', @@topics_classvars[:zk_host]).chomp
    topic_info = output.match(TOPIC_REGEX)
    {ensure: :present,
     name: topic_info['topicname'],
     num_partitions: topic_info['numpartition'],
     replication_factor: topic_info['rep_factor'],
     provider: :confluent}
  end

  def create
    @property_flush[:ensure] = :present

  end

  def exists?
    @@topics_classvars[:topics].include?(resource[:name])
  end

  def destroy
    @property_flush[:ensure] = :absent

  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resources['prov'] = resources[prov.name]
        resources['prov'].provider = prov
      end
    end

  end

  def self.instances
    existing_topics = []
    @@topics_classvars[:topics].each do |topic|
      existing_topics << new(describe_topic(topic))
    end
    existing_topics
  end


  def do_the_job
    case @property_flush[:ensure]
      when :absent
        kafka_topics('--delete', '--force', '--topic', resource[:name], '--zookeeper', @@topics_classvars[:zk_host])
      when :present
        kafka_topics('--create',
                     '--topic', resource[:name],
                     '--zookeeper', @@topics_classvars[:zk_host],
                     '--partitions', resource[:num_partitions],
                     '--replication-factor', resource[:replication_factor])
    end
  end

  def flush
    do_the_job
    @property_hash = self.class.describe_topic(resource[:name])
  end


  def correct_params?(hash_topic)
    resource_hash = {name: resource[:name],
                     num_partitions: resource[:num_partitions],
                     replication_factor: resource[:replication_factor],
                     zookeeper: resource[:zookeeper]}
    raise ArgumentError, ('Can\t update topic for now. Current settings != new settings') unless hash_topic == resource_hash
  end
end
