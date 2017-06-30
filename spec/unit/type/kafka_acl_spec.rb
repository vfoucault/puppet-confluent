require 'spec_helper'

describe Puppet::Type.type(:kafka_acl) do

  let(:resource) do
    Puppet::Type.type(:kafka_acl).new(
        title: 'test_topictest_acl',
        resource: 'TOPICTEST'
    )
  end

  describe 'Fails if missing on of required parameters' do
    it 'failed validation with missing user parameter' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'all',
                                  type: 'topic',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /User parameter is mandatory/)
    end
    it 'failed validation with missing resource parameter' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  operation: 'all',
                                  type: 'topic',
                                  user: 'User:bob',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /Resource parameter is mandatory/)
    end
    it 'failed validation with missing action parameter' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'all',
                                  user: 'User:bob',
                                  type: 'topic')}.to raise_error(Puppet::ResourceError, /Action parameter is mandatory/)
    end
    it 'failed validation with missing operation parameter' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  type: 'topic',
                                  user: 'User:bob',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /Operation parameter is mandatory/)
    end
    it 'failed validation with missing type parameter' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'all',
                                  user: 'User:bob',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /Type parameter is mandatory/)
    end
  end
  describe 'Fails with bad options' do
    it 'failed with bad option for type' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'all',
                                  type: 'bla',
                                  user: 'User:bob',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /Invalid value "bla". Valid values are topic, cluster, group./)
    end
    it 'does not fails with correct option for type' do
      %w[cluster topic group].each do |type|
        expect {described_class.new(title: 'test_topictest_acl',
                                    resource: 'TOPICTEST1',
                                    operation: 'all',
                                    type: type,
                                    user: 'User:bob',
                                    action: 'allow')}.not_to raise_error
      end
    end
    it 'failed with bad option for operation' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'bla',
                                  type: 'cluster',
                                  user: 'User:bob',
                                  action: 'allow')}.to raise_error(Puppet::ResourceError, /Invalid value "bla". Valid values are read, write, create, delete, alter, describe, clusteraction, all./)
    end
    it 'does not fails with correct option for type' do
      %w[read write create delete alter describe clusteraction all].each do |ops|
        expect {described_class.new(title: 'test_topictest_acl',
                                    resource: 'TOPICTEST1',
                                    operation: ops,
                                    type: 'topic',
                                    user: 'User:bob',
                                    action: 'allow')}.not_to raise_error
      end
    end
    it 'failed with bad option for action' do
      expect {described_class.new(title: 'test_topictest_acl',
                                  resource: 'TOPICTEST1',
                                  operation: 'read',
                                  type: 'cluster',
                                  user: 'User:bob',
                                  action: 'bla')}.to raise_error(Puppet::ResourceError, /Invalid value "bla". Valid values are allow, deny./)
    end
    it 'does not fails with correct option for type' do
      %w[allow deny].each do |action|
        expect {described_class.new(title: 'test_topictest_acl',
                                    resource: 'TOPICTEST1',
                                    operation: 'read',
                                    type: 'topic',
                                    user: 'User:bob',
                                    action: action)}.not_to raise_error
      end
    end
  end


end
