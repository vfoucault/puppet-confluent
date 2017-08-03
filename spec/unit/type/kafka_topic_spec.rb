require 'spec_helper'

describe Puppet::Type.type(:kafka_topic) do

  let(:resource) do
    Puppet::Type.type(:kafka_topic).new(
        name: 'TOPICTEST'
    )
  end

  context 'resource defaults' do
    it { expect(resource[:partitions]).to eq 3 }
    it { expect(resource[:replication]).to eq 3 }
  end

  describe 'property `name`' do
    it 'passes validation with correct name' do
      expect { described_class.new(name: 'TOPICTEST1') }.not_to raise_error
    end
    it 'passes validation with dash and underscore in name' do
      expect { described_class.new(name: 'TO-PIC_TEST1') }.not_to raise_error
    end
    it 'fails validation with a space in the name' do
      expect { described_class.new(name: 'TOPIC TEST')}.to raise_error Puppet::Error, %r{Topic name should match alpha, _ and -}
    end
    it 'fails validation with a special char in the name' do
      expect { described_class.new(name: 'TOPIC%TEST')}.to raise_error Puppet::Error, %r{Topic name should match alpha, _ and -}
    end
  end

  describe 'property `replication`' do
    it 'passes validation with a correct valid integer' do
      expect { described_class.new(name: 'TOPICTEST', replication: '3') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', replication: ' 3 ') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', replication: 3) }.not_to raise_error
    end

    it 'fails validation with an incorrect value' do
      expect { described_class.new(name: 'TOPICTEST', replication: 'three') }.to raise_error Puppet::ResourceError, %r{the replication factor must be an integer}
      expect { described_class.new(name: 'TOPICTEST', replication: '4 5') }.to raise_error Puppet::ResourceError, %r{the replication factor must be an integer}
    end
  end

  describe 'property `partitions`' do
    it 'passes validation with a correct valid integer' do
      expect { described_class.new(name: 'TOPICTEST', partitions: '3') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', partitions: ' 3 ') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', partitions: 3) }.not_to raise_error
    end

    it 'fails validation with an incorrect value' do
      expect { described_class.new(name: 'TOPICTEST', partitions: 'three') }.to raise_error Puppet::ResourceError, %r{the number of partitions must be an integer}
      expect { described_class.new(name: 'TOPICTEST', partitions: '4 5') }.to raise_error Puppet::ResourceError, %r{the number of partitions must be an integer}
    end
  end

  describe 'property `config`' do
    it 'passes validation with a correct valid hash' do
      expect { described_class.new(name: 'TOPICTEST', config: {}) }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', config: {'key' => 'value'}) }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', config: {'key' => 'value', 'key2' => 'value2'}) }.not_to raise_error
    end

    it 'fails validation with an incorrect value' do
      expect { described_class.new(name: 'TOPICTEST', config: ['abc', '123']) }.to raise_error Puppet::ResourceError, %r{the configuration must be a key/value hash}
    end
  end

  describe 'when creating resources' do

    it 'creating resource should not fail with correct parameters' do

      expect { Puppet::Type.type(:kafka_topic).new(
          name: 'TESTTOPIC1',
          ensure: :present,
          partitions: '3',
          replication: '4'
      ) }.not_to raise_error

    end
    it 'creating resource should fail with incorrect parameter' do

      expect { Puppet::Type.type(:kafka_topic).new(
          name: 'TESTTOPIC1',
          ensure: :present,
          partitions: '3',
          replication: '4',
          bladibla: '4'
      ) }.to raise_error Puppet::Error #, %r{Invalid parameter named 'bladibla'}


    end
  end
end
