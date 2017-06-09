Puppet::Type.newtype(:kafkatopic) do
  ensurable

  newparam(:name, isnamevar: true) do
    desc 'The kafka topic name'

    validate do |name|
      raise ArgumentError, 'Topic name should match alpha, _ and -' unless name =~ /^[_\-a-zA-Z0-9]*$/
    end
  end

  newproperty(:zookeeper) do
    desc 'A zookeper instance to use'

    validate do |zookeeper|
      raise ArgumentError, 'zookeeper is a hostname with an optional port name' unless zookeeper =~ /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])(:\d{1,5})?$/
    end
  end

  newproperty(:replication_factor) do
    desc 'The topic\'s replication factor'

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

    validate do |num|
      begin
        Integer(num)
      rescue
        raise ArgumentError, 'the number of partitions must be an integer'
      end
    end
  end


  newproperty(:extra_path) do
    desc 'Extra path to locate kafka-topics command'
    validate do |extra_path|
      extra_path.split(':').each do |path|
        raise ArgumentError, 'Extra path is a list separated by \':\'' unless absolute_path? path
      end
    end
  end
end
