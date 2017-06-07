# require 'spec_helper'
# require 'minitest/mock'
# require 'stringio'
#
#
# describe Puppet::Type.type(:kafka_topic).provider(:confluent) do
#
#   let(:zk_host) { StringIO.new("zookeeper.connect=zoo1.keeper.localnet:2181")}
#
#   let(:raw_one_host) do
#     <<-OUTPUT
# zookeeper.connect=zoo1.keeper.localnet:2181
#
# # Timeout in ms for connecting to zookeeper
# zookeeper.connection.timeout.ms=1000000
#     OUTPUT
#   end
#
#   let(:raw_hosts) do
#     <<-OUTPUT
# zookeeper.connect=zoo1.keeper.localnet:2181,zoo2.keeper.localnet:2181,zoo3.keeper.localnet:2181
#
# # Timeout in ms for connecting to zookeeper
# zookeeper.connection.timeout.ms=1000000
#     OUTPUT
#   end
#
#   let(:described_topics) do
#     <<-OUTPUT
#    Topic:topic1	PartitionCount:3	ReplicationFactor:3	Configs:
#    	Topic: topic1	Partition: 0	Leader: 1	Replicas: 1,3,2	Isr: 1,3,2
#    	Topic: topic1	Partition: 1	Leader: 2	Replicas: 2,1,3	Isr: 2,1,3
#    	Topic: topic1	Partition: 2	Leader: 3	Replicas: 3,2,1	Isr: 3,2,1
#    Topic:topic2	PartitionCount:2	ReplicationFactor:2	Configs:
#    	Topic: topic2	Partition: 0	Leader: 1	Replicas: 1,2 	Isr: 1,2,3
#    	Topic: topic2	Partition: 1	Leader: 2	Replicas: 2,1 	Isr: 2,1,3
#    Topic:TestTopic	PartitionCount:1	ReplicationFactor:1	Configs:
#    	Topic: TestTopic	Partition: 0	Leader: 1	Replicas: 1 	Isr: 1,2,3
#     OUTPUT
#   end
#
#   let(:raw_databases) do
#     <<-SQL_OUTPUT
# information_schema
# mydb
# mysql
# performance_schema
# test
#     SQL_OUTPUT
#   end
#
#   let(:resource) { Puppet::Type.type(:kafka_topic).new(
#       { :ensure             => :present,
#         :name               => 'HEYTOPIC',
#         :replication_factor => 2,
#         :num_partitions     => 2,
#         :provider => described_class.name
#       }
#   )}
#   let(:provider) { resource.provider }
#
#   before :each do
#     # let(:file_like_object) { double("file like object") }
#     Puppet::Util.stubs(:which).with('/usr/bin/kafka-topics').returns('/usr/bin/kafka-topics')
#     # File.stubs(:file?).with('/etc/kafka/server.properties').returns(true)
#     # File.stubs(:open).with('/etc/kafka/server.properties').returns(zk_host)
#     # File.stub(:open).and_return(zk_host)
#     # File.any_instance.stub(:open) { zk_host }
#     # File.any_instance.stubs(:open).returns(zk_host)
#     provider.class.stubs(:get_zk_host).returns('zoo1.keeper.localnet:2182')
#     mock = MiniTest::Mock.new
#     mock.expect(:new, true)
#     mock.expect(:close, nil)
#     TCPSocket.stubs(:new).returns(mock)
#   end
#
#   let(:instance) { provider.class.instances.first }
#
#   describe 'self.instances' do
#
#     it 'returns an array of topics' do
#       provider.class.stubs(:kafka_topic).returns(described_topics)
#       # provider.class.stubs(:kafka_topic).with('--describe', '--zookeeper', 'zoo1.keeper.localnet:2181').returns(described_topics)
#       topics = provider.class.instances.collect {|x| x.name }
#       # expect(parsed_databases).to match_array(databases)
#     end
#   end
#   # output = kafka_topics('--describe', '--zookeeper', get_zk_host).chomp
#   # describe 'self.prefetch' do
#   #   it 'exists' do
#   #     provider.class.instances
#   #     provider.class.prefetch({})
#   #   end
#   # end
#
#   # describe 'create' do
#   #   it 'makes a database' do
#   #     provider.expects(:mysql).with([defaults_file, '-NBe', "create database if not exists `#{resource[:name]}` character set `#{resource[:charset]}` collate `#{resource[:collate]}`"])
#   #     provider.expects(:exists?).returns(true)
#   #     expect(provider.create).to be_truthy
#   #   end
#   # end
#   #
#   # describe 'destroy' do
#   #   it 'removes a database if present' do
#   #     provider.expects(:mysql).with([defaults_file, '-NBe', "drop database if exists `#{resource[:name]}`"])
#   #     provider.expects(:exists?).returns(false)
#   #     expect(provider.destroy).to be_truthy
#   #   end
#   # end
#   #
#   # describe 'exists?' do
#   #   it 'checks if database exists' do
#   #     expect(instance.exists?).to be_truthy
#   #   end
#   # end
#   #
#   # describe 'self.defaults_file' do
#   #   it 'sets --defaults-extra-file' do
#   #     File.stubs(:file?).with('/root/.my.cnf').returns(true)
#   #     expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
#   #   end
#   #   it 'fails if file missing' do
#   #     File.stubs(:file?).with('/root/.my.cnf').returns(false)
#   #     expect(provider.defaults_file).to be_nil
#   #   end
#   # end
#   #
#   # describe 'charset' do
#   #   it 'returns a charset' do
#   #     expect(instance.charset).to eq('latin1')
#   #   end
#   # end
#   #
#   # describe 'charset=' do
#   #   it 'changes the charset' do
#   #     provider.expects(:mysql).with([defaults_file, '-NBe', "alter database `#{resource[:name]}` CHARACTER SET blah"]).returns('0')
#   #
#   #     provider.charset=('blah')
#   #   end
#   # end
#   #
#   # describe 'collate' do
#   #   it 'returns a collate' do
#   #     expect(instance.collate).to eq('latin1_swedish_ci')
#   #   end
#   # end
#   #
#   # describe 'collate=' do
#   #   it 'changes the collate' do
#   #     provider.expects(:mysql).with([defaults_file, '-NBe', "alter database `#{resource[:name]}` COLLATE blah"]).returns('0')
#   #
#   #     provider.collate=('blah')
#   #   end
#   # end
#
# end
#
# # require 'spec_helper'
# # provider_class = Puppet::Type.type(:kafka_topic).provider(:confluent)
# #
# # context 'installing vendor-modulename' do
# #
# #   let(:list_topics) do
# #     <<-OUTPUT
# #   topic1
# #   topic2
# #   TestTopic
# #     OUTPUT
# #   end
# #   let(:list_topics_details_topic1) do
# #     <<-OUTPUT
# #   Topic:topic1	PartitionCount:3	ReplicationFactor:3	Configs:
# #   	Topic: topic1	Partition: 0	Leader: 1	Replicas: 1,3,2	Isr: 1,3,2
# #   	Topic: topic1	Partition: 1	Leader: 2	Replicas: 2,1,3	Isr: 2,1,3
# #   	Topic: topic1	Partition: 2	Leader: 3	Replicas: 3,2,1	Isr: 3,2,1
# #     OUTPUT
# #   end
# #   let(:list_topics_details_topic2) do
# #     <<-OUTPUT
# #   Topic:topic2	PartitionCount:2	ReplicationFactor:2	Configs:
# #   	Topic: topic2	Partition: 0	Leader: 1	Replicas: 1,2 	Isr: 1,2
# #   	Topic: topic2	Partition: 1	Leader: 2	Replicas: 2,1 	Isr: 2,1
# #     OUTPUT
# #   end
# #   let(:list_topics_details_TestTopic) do
# #     <<-OUTPUT
# #   Topic:TestTopic	PartitionCount:1	ReplicationFactor:1	Configs:
# #   	Topic: TestTopic	Partition: 0	Leader: 1	Replicas: 1 	Isr: 1
# #     OUTPUT
# #   end
# #
# #   let(:get_zk_host) do
# #     <<-OUTPUT
# #   clientPort=2181
# #   server.1 = zookeeper1.corp:2188:2888
# #     OUTPUT
# #   end
# #