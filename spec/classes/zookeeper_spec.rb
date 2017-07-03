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

      let(:params) {
        {
            'zookeeper_id' => '1',
        }
      }

      context 'basic setup' do
        expected_heap = '-Xmx256M'

        it {is_expected.to contain_ini_subsetting('zookeeper_KAFKA_HEAP_OPTS').with(
            {
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
      end
    end
  end
end