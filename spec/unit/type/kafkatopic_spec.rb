require 'spec_helper'

describe Puppet::Type.type(:kafkatopic) do
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

  describe 'property `zookeeper`' do
    it 'passes validation with a correct host name' do
      expect { described_class.new(name: 'TOPICTEST', zookeeper: 'faksehostname:2181') }.not_to raise_error
    end
    it 'fails validation with an incorrect host name' do
      expect { described_class.new(name: 'TOPICTEST', zookeeper: 'some%hostname') }.to raise_error Puppet::Error, %r{zookeeper is a hostname with an optional port name}
    end
  end

  describe 'property `replication_factor`' do
    it 'passes validation with a correct valid integer' do
      expect { described_class.new(name: 'TOPICTEST', replication_factor: '3') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', replication_factor: ' 3 ') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', replication_factor: 3) }.not_to raise_error
    end

    it 'fails validation with an incorrect value' do
      expect { described_class.new(name: 'TOPICTEST', replication_factor: 'three') }.to raise_error Puppet::ResourceError, %r{the replication factor must be an integer}
      expect { described_class.new(name: 'TOPICTEST', replication_factor: '4 5') }.to raise_error Puppet::ResourceError, %r{the replication factor must be an integer}
    end
  end

  describe 'property `num_partitions`' do
    it 'passes validation with a correct valid integer' do
      expect { described_class.new(name: 'TOPICTEST', num_partitions: '3') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', num_partitions: ' 3 ') }.not_to raise_error
      expect { described_class.new(name: 'TOPICTEST', num_partitions: 3) }.not_to raise_error
    end

    it 'fails validation with an incorrect value' do
      expect { described_class.new(name: 'TOPICTEST', num_partitions: 'three') }.to raise_error Puppet::ResourceError, %r{the number of partitions must be an integer}
      expect { described_class.new(name: 'TOPICTEST', num_partitions: '4 5') }.to raise_error Puppet::ResourceError, %r{the number of partitions must be an integer}
    end
  end

  describe 'property `extra_path`' do
    it 'passes validation with an list of correct paths path' do
      expect { described_class.new(name: 'TOPICTEST', extra_path: '/usr/bin:/usr/sbin/:/opt/path/to/bins') }.not_to raise_error
    end
    it 'fails validation without an absolute path' do
      expect { described_class.new(name: 'TOPICTEST', extra_path: "bladibla") }.to raise_error Puppet::ResourceError, %r{Extra path is a list separated by ':'}
    end
  end

  describe 'when creating resources' do

    it 'creating resource should not fail with correct parameters' do

      expect { Puppet::Type.type(:kafkatopic).new(
          name: 'TESTTOPIC1',
          ensure: :present,
          zookeeper: 'zookeeperhost1:2181',
          num_partitions: '3',
          replication_factor: '4'
      ) }.not_to raise_error

    end
    it 'creating resource should fail with incorrect parameter' do

      expect { Puppet::Type.type(:kafkatopic).new(
          name: 'TESTTOPIC1',
          ensure: :present,
          zookeeper: 'zookeeperhost1:2181',
          num_partitions: '3',
          replication_factor: '4',
          bladibla: '4'
      ) }.to raise_error Puppet::Error, %r{Invalid parameter bladibla}


    end
  end
end
