#
Puppet::Type.type(:kafka_topic).provide(:confluent) do
  TOPIC_REGEX = %r{Topic:(?'topicname'[\S]*).*PartitionCount:(?'numpartition'\d{1,2}).*ReplicationFactor:(?'rep_factor'\d{1,2})}
  commands kafka_topics: '/usr/bin/kafka-topics'

  def get_topics
    kafka_topics('--list', '--zookeeper', resource[:zookeeper]).chomp.split("\n")
  end

  def describe_topic
    output = kafka_topics('--describe', '--topic', resource[:name], '--zookeeper', resource[:zookeeper]).chomp
    topic_info = output.match(TOPIC_REGEX)
    {name: topic_info['topicname'], num_partitions: topic_info['numpartition'], replication_factor: topic_info['rep_factor']}
  end

  def exists?
    if get_topics.include?(resource[:name])
      return true
    end
    return false
  end

  def create
    kafka_topics('--create', '--topic', resource[:name], '--zookeeper', resource[:zookeeper])
  end

  def destroy
    kafka_topics('--delete', '--force', '--topic', resource[:name], '--zookeeper', resource[:zookeeper])
  end

  def correct_params?
    topic_info = describe_topic
    resource_hash = {name: resource[:name],
                     num_partitions: resource[:num_partitions],
                     replication_factor: resource[:replication_factor],
                     zookeeper: resource[:zookeeper]}
    raise ArgumentError, ('Can\t update topic for now. Current settings != new settings') unless topic_info == resource_hash
  end
end
