require 'spec_helper'

describe Puppet::Type.type(:kafka_connect) do

  let(:resource) do
    Puppet::Type.type(:kafka_connect).new(
        name: 'CONNECT_TEST',
        connect: { "connect.class" => "test.class" }

    )
  end


  describe 'property `name`' do
    it 'passes validation with correct name' do
      expect { described_class.new(name: 'CONNECT_TEST') }.not_to raise_error
    end
    it 'passes validation with dash and underscore in name' do
      expect { described_class.new(name: 'CON-NECT_test1') }.not_to raise_error
    end
    it 'fails validation with a space in the name' do
      expect { described_class.new(name: 'CONNECT TEST')}.to raise_error Puppet::Error, %r{Connect name should match alpha, _ and -}
    end
    it 'fails validation with a special char in the name' do
      expect { described_class.new(name: 'connect%test')}.to raise_error Puppet::Error, %r{Connect name should match alpha, _ and -}
    end
  end

  describe 'property `connect`' do
    it 'passes validation with a correct valid Hash' do
      expect { described_class.new(name: 'CONNECT_TEST', connect: {:abc => 123}) }.not_to raise_error
    end

    it 'fails validation with an incorrect hash' do
      expect { described_class.new(name: 'CONNECT_TEST', connect: ['abc', '123']) }.to raise_error Puppet::ResourceError, %r{Connect must be a hash}
      expect { described_class.new(name: 'CONNECT_TEST', connect: 'abc') }.to raise_error Puppet::ResourceError, %r{Connect must be a hash}
    end
  end

  describe 'when creating resources' do

    it 'creating resource should not fail with correct parameters' do

      expect { Puppet::Type.type(:kafka_connect).new(
          name: 'kafka101',
          ensure: :present,
          connect: {},
      ) }.not_to raise_error

    end
    it 'creating resource should fail with incorrect parameter' do

      expect { Puppet::Type.type(:kafka_connect).new(
          name: 'kafka101',
          ensure: :present,
          connect: {},
          bladibla: '4'
      ) }.to raise_error Puppet::Error #, %r{Invalid parameter named 'bladibla'}

    end
  end
end
