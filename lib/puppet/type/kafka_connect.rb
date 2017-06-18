Puppet::Type.newtype(:kafka_connect, :self_refresh => false) do
  @doc = 'Operate kafka connect api.'

  ensurable do
    desc 'whether connect task should be present/absent (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:pause) do
      provider.destroy
    end

    defaultto(:present)

  end

  newparam(:name) do
    desc 'connect name'
  end

  newparam(:type) do
    desc 'connect type'
    newvalue(:standalone)
    newvalue(:distributed)
    defaultto(:distributed)
  end

  newproperty(:class) do
    desc 'The connector class'
  end

  newproperty(:max_tasks) do
    desc 'The connector maximum number of tasks'
  end

  newproperty(:extra_config) do
    desc 'Extra configuration (hash)'
    validate do |extra_config|
      begin
        Hash(extra_config)
      rescue
        raise ArgumentError, 'the replication factor must be an integer'
      end
    end
  end
end
