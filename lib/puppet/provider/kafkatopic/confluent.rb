Puppet::Type.type(:kafkatopic).provide(:confluent) do
  # confine osfamily: :redhat
  # defaultfor osfamily: :redhat

  commands kafka_topic_cmd: '/usr/bin/kafka-topics'


  # has_feature :mode

  # Return all instances for this provider
  #
  # @return [Array<Puppet::Type::Alternatives::ProviderDpkg>] A list of all current provider instances
  def self.instances
    all.map {|name, attributes| new(name: name,
                                    zookeeper: @resource.value(:zookeeper),
                                    num_partitions: attributes[:num_partitions],
                                    replication_factor: attributes[:replication_factor])}
  end

  def exists?
    self.list_topics.each_line do |topicname|
      topicname == @resource.value(:name)
    end
  end

  TOPIC_REGEX = %r{Topic:(?'topicname'[\S]*).*PartitionCount:(?'numpartition'\d{1,2}).*ReplicationFactor:(?'rep_factor'\d{1,2})}

  def self.describe_topic(name)
    output = kafka_topic_cmd('--describe', '--topic', name, '--zookeeper', @resource.value(:zookeeper))
    topic_info = output.match(TOPIC_REGEX)
    {name: topic_info['topicname'], num_partitions: topic_info['numpartition'], replication_factor: topic_info['rep_factor']}
  end

  def self.list_topics
    ignored_topics = %w{__confluent.support.metrics _schemas}
    kafka_topic_cmd('--list', '--zookeeper', @resource.value(:zookeeper)).split("\n").select {|x| !ignored_topics.include?(x)}
  end

  def self.all
    return_hash = {}
    self.list_topics.each do |topic_name|
      info = self.describe_topic(topic_name)
      return_hash[topic_name] = info
    end
    return_hash
  end

  def create
    kafka_topic_cmd('--create',
                    '--topic',
                    @resource.value(:name),
                    '--zookeeper',
                    @resource.value(:zookeeper),
                    '--partitions',
                    @resource.value(:num_partitions),
                    '--replication-factor',
                    @resource.value(:replication_factor))
  end

end


# Puppet::Type.type(:kafkatopic).provide(:confluent) do
#
#   commands kafka_topic_cmd: '/usr/bin/kafka-topics'
#
#
#   mk_resource_methods
#
#   def create
#     kafka_topic_cmd('--create',
#            '--topic',
#            @resource.value(:name),
#            '--zookeeper',
#            @resource.value(:zookeeper),
#            '--partitions',
#            @resource.value(:num_partitions),
#            '--replication-factor',
#            @resource.value(:replication_factor))
#   end
#
#   # @return [Array<Puppet::Type::Alternatives::ProviderDpkg>] A list of all current provider instances
#   def self.instances
#     all.map { |name, attributes| new(name: name, path: attributes[:path]) }
#   end
#
#   def self.list_topics
#     kafka_topic_cmd('--list', '--zookeeper', @resource.value(:zookeeper)).chomp()
#   end
#
#   def exists?
#     self.list_topics.each do |topicname|
#       topicname == @resource.value(:name)
#     end
#   end
#
#   def destroy
#     begin
#       kafka_topic_cmd('--delete', '--topic', @resource.value(:name), '--force')
#     rescue
#     end
#   end
#
#   def self.instances
#     entries = []
#     self.list_topics.each do |topic|
#       entries << new(query_topic(topic))
#     end
#
#     entries
#   end
#
#
#   def self.prefetch(resources)
#     instances.each do |prov|
#       # rubocop:disable Lint/AssignmentInCondition
#       if resource = resources[prov.name]
#         # rubocop:enable Lint/AssignmentInCondition
#         resource.provider = prov
#       end
#     end
#   end
#
#   TOPIC_REGEX = %r{Topic:(?'topicname'[\S]*).*PartitionCount:(?'numpartition'\d{1,2}).*ReplicationFactor:(?'rep_factor'\d{1,2})}
#
#   def self.query_topic(name)
#     output = kafka_topic_cmd('--describe', '--topic', name, '--zookeeper', @resource.value(:zookeeper))
#     topic_info = output.match(TOPIC_REGEX)
#     {name: topic_info['topicname'], num_partitions: topic_info['numpartition'], replication_factor: topic_info['rep_factor']}
#   end
#
#   def name=(new_name)
#     rebuild do
#       @property_hash[:name] = new_name
#     end
#   end
#
#   def num_partitions=(new_num_partitions)
#     rebuild do
#       @property_hash[:num_partitions=] = new_num_partitions
#     end
#   end
#
#   def replication_factor(new_replication_factor)
#     rebuild do
#       @property_hash[:replication_factor] = new_replication_factor
#     end
#   end
# end
#
