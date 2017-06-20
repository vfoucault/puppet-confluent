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

    defaultto(:present)
  end

  newparam(:name) do
    desc 'Connect name'
    validate do |value|
      unless value =~ /^[_\-a-zA-Z0-9]*$/
        raise ArgumentError, 'Connect name should match alpha, _ and -'
      end
    end
  end

  newproperty(:connect) do
    desc 'configuration (hash)'
    validate do |connect|
      unless connect.is_a?(Hash)
        raise ArgumentError, 'Connect must be a hash'
      end
    end
  end
end
