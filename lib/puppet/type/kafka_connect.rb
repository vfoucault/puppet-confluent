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
  end


  newproperty(:connect) do
    desc 'Extra configuration (hash)'
    validate do |connect|
      begin
        Hash(connect)
      rescue
        raise ArgumentError, 'Connect must be a hash'
      end
    end
  end
end
