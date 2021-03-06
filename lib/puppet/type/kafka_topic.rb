Puppet::Type.newtype(:kafka_topic, :self_refresh => false) do
  @doc = 'List, create and delete kafka topics.'

  ensurable do
    desc 'whether topic file should be present/absent (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)

  end

  newparam(:name) do
    desc 'topic name'
    validate do |value|
      unless value =~ /^[_\-a-zA-Z0-9]*$/
        raise ArgumentError, 'Topic name should match alpha, _ and -'
      end
    end
  end

  newproperty(:replication) do
    desc 'The topic\'s replication factor'
    defaultto(3)
    validate do |replication|
      begin
        Integer(replication)
      rescue
        raise ArgumentError, 'the replication factor must be an integer'
      end
    end
  end

  newproperty(:partitions) do
    desc 'The topic\'s number of partitions'
    defaultto(3)
    validate do |num|
      begin
        Integer(num)
      rescue
        raise ArgumentError, 'the number of partitions must be an integer'
      end
    end
  end
end
