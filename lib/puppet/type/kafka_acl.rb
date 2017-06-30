Puppet::Type.newtype(:kafka_acl, :self_refresh => false) do
  @doc = 'List, create and delete kafka acls.'

  ensurable do
    desc 'whether acl should be present/absent (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)

  end

  def self.title_patterns
    # This is the default title pattern for all types, except hard-wired to
    # set only name.
    # [ [ /(.*)/m, [ [:type] ] ] ]
    [ [ /(.*)/m, [ ] ] ]

  end

  newparam(:type, :namevar => true) do
    desc 'the acl type. Can be Topic, Cluster or Group'
    # will be based on
    newvalues(:topic, :cluster, :group)
  end

  newparam(:resource, :namevar => true) do
    desc 'The resource for the acl.'
    validate do |value|
      unless value =~ /^[_\-a-zA-Z0-9]*$/
        raise ArgumentError, 'resource should match alpha, _ and -'
      end
    end
  end

  newparam(:action, :namevar => true) do
    desc 'The action, deny or allow'
    newvalues(:allow, :deny)
  end

  newparam(:operation, :namevar => true) do
    desc 'The operation to allow of deny'
    newvalues(:read, :write, :create, :delete, :alter, :describe, :clusteraction, :all)
  end

  newparam :user, :namevar => true

  newparam :host, :namevar => true


  validate do
    fail('User parameter is mandatory.') if self[:user].nil?
    fail('Operation parameter is mandatory.') if self[:operation].nil?
    fail('Action parameter is mandatory.') if self[:action].nil?
    fail('Resource parameter is mandatory.') if self[:resource].nil?
    fail('Type parameter is mandatory.') if self[:type].nil?
  end
end
