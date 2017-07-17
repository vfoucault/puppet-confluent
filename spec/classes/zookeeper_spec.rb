require 'spec_helper'

describe 'confluent::zookeeper' do


  %w(RedHat Debian).each do |osfamily|
    context "with osfamily => #{osfamily}" do
      environment_file = nil

      case osfamily
        when 'Debian'
          environment_file = '/etc/default/zookeeper'
        when 'RedHat'
          environment_file = '/etc/sysconfig/zookeeper'
      end

      let(:facts) {
        {
            'osfamily' => osfamily
        }
      }

      context 'basic setup' do
        let(:params) {
          {
              'zookeeper_id' => '1',
          }
        }
        expected_heap = '-Xmx256M'

        it {is_expected.to contain_ini_setting('zookeeper_KAFKA_HEAP_OPTS').with(
            {
                'setting' => 'KAFKA_HEAP_OPTS',
                'path' => environment_file,
                'value' => expected_heap
            }
        )}

        it {is_expected.to contain_package('confluent-kafka-2.11')}
        it {is_expected.to contain_user('zookeeper')}
        it {is_expected.to contain_service('zookeeper').with(
            {
                'ensure' => 'running',
                'enable' => true
            }
        )}
        it {is_expected.to contain_file('/var/log/zookeeper')}
        it {is_expected.to contain_file('/var/lib/zookeeper')}
        it {is_expected.to contain_file('/var/lib/zookeeper/myid')
                               .with_owner('zookeeper')
                               .with_group('zookeeper')
                               .with_content('1')
                               .that_requires('User[zookeeper]')}
      end

      context 'basic setup with zookeeper_id as integer' do
        let(:params) {
          {
              'zookeeper_id' => 1,
          }
        }
        it {is_expected.to contain_file('/var/lib/zookeeper/myid')
                               .with_owner('zookeeper')
                               .with_group('zookeeper')
                               .with_content('1')
                               .that_requires('User[zookeeper]')}
      end
    end
  end
end