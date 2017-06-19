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
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, 'Topic name should match alpha, _ and -' unless value =~ /^[_\-a-zA-Z0-9]*$/
      end
    end
  end

  newproperty(:replication_factor) do
    desc 'The topic\'s replication factor'
    defaultto(3)
    validate do |replication_factor|
      begin
        Integer(replication_factor)
      rescue
        raise ArgumentError, 'the replication factor must be an integer'
      end
    end
  end

  newproperty(:num_partitions) do
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

  newparam(:extra_path) do
    desc 'Extra path to locate kafka-topics command'
    validate do |extra_path|
      extra_path.split(':').each do |path|
        raise ArgumentError, 'Extra path is a list separated by \':\'' unless absolute_path? path
      end
    end
  end
end
