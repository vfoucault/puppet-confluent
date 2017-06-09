require 'spec_helper'

describe Puppet::Type.type(:kafka_topic).provider(:confluent) do
  def fixture_topics_list
    return %w{topic1 topic2 TestENTRY}
  end
  def fixture_describe_topic(name, part, factor)
    {name: name, num_partitions: part, replication_factor: factor}
  end

  def my_fixture_display(type, path)
    File.join(PROJECT_ROOT, 'spec', 'fixtures', 'unit', 'provider', 'alternatives', 'rpm', type, path)
  end


  def my_fixture_read(type, path)
    File.read(my_fixture_display(type, path))
  end

  let(:stub_selections) do
    {
        'topic3'  => { name: "topic3", zookeeper: 'zookeeper:2181', num_paritions: 1, replication_factor: 2  }
    }
  end

  describe '.all' do
    it 'List all kafka topics:' do
      described_class.expects(:list_topics).returns fixture_topics_list
      described_class.expects(:describe_topic).with('topic1').returns fixture_describe_topic('topic1', 2, 3)
      described_class.expects(:describe_topic).with('topic2').returns fixture_describe_topic('topic2', 3, 2)
      described_class.expects(:describe_topic).with('TestENTRY').returns fixture_describe_topic('TestENTRY', 14, 15)
      described_class.all

    end

    describe 'returning data' do
      before do
        described_class.stubs(:list_topics).returns fixture_topics_list
        described_class.expects(:describe_topic).with('topic1').returns fixture_describe_topic('topic1', 2, 3)
        described_class.expects(:describe_topic).with('topic2').returns fixture_describe_topic('topic2', 3, 2)
        described_class.expects(:describe_topic).with('TestENTRY').returns fixture_describe_topic('TestENTRY', 14, 15)
      end

      subject { described_class.all }

      it { is_expected.to be_a Hash }
      it { expect(subject['topic1']).to eq(name: "topic1", num_partitions: 2, replication_factor: 3) }
      it { expect(subject['topic2']).to eq(name: "topic2", num_partitions: 3, replication_factor: 2) }
      it { expect(subject['TestENTRY']).to eq(name: "TestENTRY", num_partitions: 14, replication_factor: 15) }
    end
  # end
  #
  describe '.instances' do
    it 'delegates to .all' do
      described_class.expects(:all).returns(stub_selections)
      described_class.expects(:new).twice.returns(stub)
      described_class.instances
    end
  end
  #
  # describe 'instances' do
  #   subject { described_class.new(name: 'sample') }
  #
  #   let(:resource) { Puppet::Type.type(:alternatives).new(name: 'sample') }
  #
  #   before do
  #     Puppet::Type.type(:alternatives).stubs(:defaultprovider).returns described_class
  #     described_class.stubs(:update).with('--display', 'sample').returns my_fixture_read('display', 'sample')
  #     described_class.stubs(:update).with('--display', 'testcmd').returns my_fixture_read('display', 'testcmd')
  #     resource.provider = subject
  #     described_class.stubs(:all).returns(stub_selections)
  #   end
  #
  #   it '#path retrieves the path from class.all' do
  #     expect(subject.path).to eq('/opt/sample1')
  #   end
  #
  #   it '#path= updates the path with alternatives --set' do
  #     subject.expects(:update).with('--set', 'sample', '/opt/sample1')
  #     subject.path = '/opt/sample1'
  #   end
  #
  #   it '#mode=(:auto) calls alternatives --auto' do
  #     subject.expects(:update).with('--auto', 'sample')
  #     subject.mode = :auto
  #   end
  #
  #   it '#mode=(:manual) calls alternatives --set with current value' do
  #     subject.expects(:path).returns('/opt/sample2')
  #     subject.expects(:update).with('--set', 'sample', '/opt/sample2')
  #     subject.mode = :manual
  #   end
  end
end
