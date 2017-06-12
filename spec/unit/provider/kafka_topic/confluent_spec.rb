require 'spec_helper'
require 'pp'

confluent_provider = Puppet::Type.type(:kafka_topic).provider(:confluent)

RSpec.describe confluent_provider do
  # it_behaves_like 'a kafka_topic provider', confluent_provider

  def fixture_describe_topic(name, part, factor)
    {name: name, num_partitions: part, replication_factor: factor}
  end

  def fixture_topics_list
    return %w{topic1 topic2 TEST_TOPIC1}
  end

  def fixture_kafka_run_cmd(action, misc_name=nil, misc_part=3, misc_factor=3)
    case action
      when :list
        return %w{topic1 topic2 TEST_TOPIC1}
      when :create
        return true
      when :delete
        return true
      when :describe
        <<-EOS
Topic:TestTopic	PartitionCount:3	ReplicationFactor:3	Configs:
	Topic: TestTopic	Partition: 0	Leader: 1	Replicas: 1,3,2	Isr: 1,3,2
	Topic: TestTopic	Partition: 1	Leader: 2	Replicas: 2,1,3	Isr: 2,1,3
	Topic: TestTopic	Partition: 2	Leader: 3	Replicas: 3,2,1	Isr: 3,2,1
EOS
      else
        raise ArgumentError, ("Unknown kafka command for action #{action}")
    end
  end

  describe 'confluent provider for non existing topic' do
    let(:name) { 'TEST_TOPIC1' }
    let(:resource_properties) do
      {
          name: name,
          zookeeper: 'fake.machine.corp:2181',
      }
    end

    let(:resource) { Puppet::Type::Kafka_topic.new(resource_properties) }
    let(:provider) { confluent_provider.new(resource) }

    # describe 'exists?' do
    #
    #   subject { provider.exists? }
    #
    #   context 'non existant topic' do
    #     it 'should not exits' do
    #       # provider.expect(:kafka_run_cmd).to receive(:action).and_wrap_original fixture_kafka_run_cmd(:action)
    #       # provider.expects(:describe_topic).returns fixture_describe_topic('TEST_TOPIC1', 2, 3)
    #       is_expected.to be_falsey
    #     end
    #   end
    # end
    describe 'instances' do
      subject { provider.instances }
      context 'existing topic' do
        it 'should load hash properties' do
          provider.expects(:kafka_run_cmd).with(:list).returns fixture_kafka_run_cmd(:list)
          provider.expects(:kafka_run_cmd).with(:describe).returns fixture_kafka_run_cmd(:describe, 'TEST_TOPIC1')
          is_expected.to be_true
        end

      end
    end
  end
  end

  # describe 'confluent provider for existing topic' do
  #   let(:name) { 'TEST_TOPIC1' }
  #   let(:resource_properties) do
  #     {
  #         name: name,
  #         zookeeper: 'fake.machine.corp:2181',
  #     }
  #   end
  #
  #   let(:resource) { Puppet::Type::Kafka_topic.new(resource_properties) }
  #   let(:provider) { confluent_provider.new(resource) }
  #
  #   describe 'exists?' do
  #
  #     subject { provider.exists? }
  #
  #     context 'existing topic' do
  #       it 'should exits' do
  #         provider.expects(:get_topics).returns fixture_topics_list
  #         provider.expects(:describe_topic).returns fixture_describe_topic('TEST_TOPIC1', 2, 3)
  #         is_expected.to be_truthy
  #
  #       end
  #     end
  #   end
    # describe 'describe_topic' do
    #
    #   subject { provider.describe_topic }
    #
    #   context 'existing topic with correct settings' do
    #     it 'should exits' do
    #       # provider.expects(:get_topics).returns fixture_topics_list
    #       provider.expects(:describe_topic).returns fixture_describe_topic('TEST_TOPIC1', 2, 3)
    #       is_expected.to eq({name: 'TEST_TOPIC1', num_partitions: 2, replication_factor: 3})
    #
    #     end
    #   end
    # end
#   end
# end






      # context 'exists' do
      #   context 'responds with hash' do
      #     it { is_expected.to eq({name: 'TEST_TOPIC1', num_partitions: 3, replication_factor: 3}) }
      #   end
        # context 'responds with hash and newline' do
        #   let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a\n" }
        #   it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        # end
        # context 'responds with `sha1sum README.md` output' do
        #   let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a  README.md\n" }
        #   it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        # end
        # context 'responds with `openssl dgst -hex -sha256 README.md` output' do
        #   let(:remote_hash) { "SHA256(README.md)= 8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428\n" }
        #   it { is_expected.to eq('8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428') }
        # end
    #   end
    # end

    # describe 'download options' do
    #   let(:resource_properties) do
    #     {
    #         name: name,
    #         source: 's3://home.lan/example.zip',
    #         download_options: ['--region', 'eu-central-1']
    #     }
    #   end
    #
    #   context 'default resource property' do
    #     it '#s3_download' do
    #       provider.s3_download(name)
    #       expect(provider).to have_received(:aws).with(s3_download_options << '--region' << 'eu-central-1')
    #     end
    #   end
    # end
#   end
# end
