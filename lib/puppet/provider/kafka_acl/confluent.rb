stringout = `kafka-acls --list --authorizer-properties zookeeper.connect=localhost:2181`.chomp


parse_raw_string(stringout)

require 'socket'
require 'timeout'

Puppet::Type.type(:kafka_acl).provide(:confluent) do
  # Without initvars commands won't work.
  initvars

  commands :kafka_acls => '/usr/bin/kafka-acls'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_zk_host
    if File.file?("/etc/kafka/server.properties")
      rawdata = File.open('/etc/kafka/server.properties').readlines().flat_map {|x| x.split("=")[1].chomp.split(',') if x =~ %r{^zookeeper.connect(\s)?=}}.compact
      alive = rawdata.map {|x| x if self.port_open?(x)}.compact
      if alive.length > 0
        return alive.sample
      else
        raise Puppet::Error, "No zookeeper host alive"
      end
    else
      raise Puppet::Error, "Unable to discover zookeeper host"
    end
  end

  def self.port_open?(uri, seconds=1)
    Timeout::timeout(seconds) do
      begin
        host, port = uri.split(":")
        TCPSocket.new(host, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def get_zk_host
    self.class.get_zk_host
  end

  def self.acls
    kafka_acls('--list', '--authorizer-properties', "zookeeper.connect=#{get_zk_host}").chomp.split("\n")
  end

  def self.instances(name=nil)
    raw_data = self.acls
    regexacl = %r{(?<aclline>(?<user>User:.*)\shas\s(?<action>Allow|Deny).*operations:\s(?<operation>\w+)\sfrom\shosts:\s(?<host>.*))}
    hash = {}
    type = nil
    resource = nil
    string.split("\n").each do |line|
      if line.start_with?("Current")
        type, resource = line.split()[-1].gsub(%r{(`|)}, '')[0..-2].split(":")
        if hash.has_key?(type)
          hash[type][resource] = []
        else
          hash[type] = {}
          hash[type][resource] = []
        end
      elsif line.length > 0
        raw_data = regexacl.match(line)
        hash[type][resource] << {:action => raw_data[:action].strip, :user => raw_data[:user].strip, :operation => raw_data[:operation].strip, :host => raw_data[:host].strip}
      end
    end
    instances = []
    hash.each do |type, entries|
      entries.each do |resource, acls|
        acls.each do |acl|
          instances << new(:ensure => :present,
                           :resource => resource,
                           :type => type,
                           :action => acl[:action],
                           :operation => acl[:operation],
                           :host => acl[:host],
                           :user => acl[:user])
        end
      end
    end
    instances
  end

  def self.prefetch(resources)
    topics = instances
    resources.keys.each do |topic|
      if provider = topics.find {|top| top.name == topic}
        resources[topic].provider = provider
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def do_the_job
    # case @property_flush[:ensure]
    #   when :absent
    #     kafka_acls('--delete', '--force', '--topic', resource[:name], '--zookeeper', get_zk_host)
    #   when :present
    #     kafka_acls('--create',
    #                '--topic', resource[:name],
    #                '--zookeeper', get_zk_host,
    #                '--partitions', resource[:partitions],
    #                '--replication-factor', resource[:replication])
    # end
  end

  def flush
    do_the_job
    @property_hash = self.class.instances()
  end
end