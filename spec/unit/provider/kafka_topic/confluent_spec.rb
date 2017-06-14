# require 'spec_helper'
# provider_class = Puppet::Type.type(:kafka_topic).provider(:confluent)
#
# context 'installing vendor-modulename' do
#
#   let(:list_topics) do
#     <<-OUTPUT
#   topic1
#   topic2
#   TestTopic
#     OUTPUT
#   end
#   let(:list_topics_details_topic1) do
#     <<-OUTPUT
#   Topic:topic1	PartitionCount:3	ReplicationFactor:3	Configs:
#   	Topic: topic1	Partition: 0	Leader: 1	Replicas: 1,3,2	Isr: 1,3,2
#   	Topic: topic1	Partition: 1	Leader: 2	Replicas: 2,1,3	Isr: 2,1,3
#   	Topic: topic1	Partition: 2	Leader: 3	Replicas: 3,2,1	Isr: 3,2,1
#     OUTPUT
#   end
#   let(:list_topics_details_topic2) do
#     <<-OUTPUT
#   Topic:topic2	PartitionCount:2	ReplicationFactor:2	Configs:
#   	Topic: topic2	Partition: 0	Leader: 1	Replicas: 1,2 	Isr: 1,2
#   	Topic: topic2	Partition: 1	Leader: 2	Replicas: 2,1 	Isr: 2,1
#     OUTPUT
#   end
#   let(:list_topics_details_TestTopic) do
#     <<-OUTPUT
#   Topic:TestTopic	PartitionCount:1	ReplicationFactor:1	Configs:
#   	Topic: TestTopic	Partition: 0	Leader: 1	Replicas: 1 	Isr: 1
#     OUTPUT
#   end
#
#   let(:get_zk_host) do
#     <<-OUTPUT
#   clientPort=2181
#   server.1 = zookeeper1.corp:2188:2888
#     OUTPUT
#   end
#
#   describe provider_class do
#     #include PuppetSpec::Fixtures
#
#     let(:resource) do
#       Puppet::Type.type(:kafka_topic).new(
#           :name => 'TestTopic2',
#           :ensure => :present,
#           :provider => 'confluent'
#       )
#     end
#
#
#     let(:provider) do
#
#       provider = provider_class.new
#       provider.stubs(:`).with('grep -E \'(server.1|clientPort)\' /etc/kafka/zookeeper.properties').returns(:get_zk_host)
#       provider.stubs(:kafka_topic).with('--list', '--zookeeper', 'zookeeper1.corp:2181').returns(:list_topics)
#       provider.resource = resource
#       provider
#     end
#
#     before :each do
#       resource.provider = provider
#     end
#
#     describe 'provider features' do
#       it { is_expected.to be_versionable }
#       it { is_expected.to be_install_options }
#       [:install, :latest, :update, :install_options].each do |method|
#         it "should have a(n) #{method}" do
#           is_expected.to respond_to(method)
#         end
#       end
#     end
#
#     # describe 'when installing' do
#     #   it 'should use the path to puppet with arguments' do
#     #     provider_class.stubs(:command).with(:puppetcmd).returns "/my/puppet"
#     #     provider.expects(:execute).with {|args| args.join(' ') == "/my/puppet module install vendor-modulename" }.returns ""
#     #     provider.install
#     #   end
#     # end
#
#   end
#
# end
# # require 'spec_helper'
# # require 'pp'
# #
# # confluent_provider = Puppet::Type.type(:kafka_topic).provider(:confluent)
# #
# # describe confluent_provider do
# #   # it_behaves_like 'a kafka_topic provider', confluent_provider
# #
#
# #
# #     context 'the whole init' do
# #
# #       describe 'instances' do
# #         it 'should have an instance method' do
# #           expect(described_class).to respond_to :instances
# #         end
# #       end
# #
# #       describe 'prefetch' do
# #         it 'should have a prefetch method' do
# #           expect(described_class).to respond_to :prefetch
# #         end
# #       end
# #     end
# #
# #   context 'get topics' do
# #     before :each do
#
# #     end
# #     it 'should return no resources' do
# #       expect(described_class.instances.size).to eq(0)
# #     end
# #   end
# # end
# #
