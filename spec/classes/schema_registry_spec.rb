require 'spec_helper'

describe 'confluent::schema::registry' do
  %w(RedHat Debian).each do |osfamily|
    context "with osfamily => #{osfamily}" do
      environment_file = nil

      case osfamily
        when 'Debian'
          environment_file = '/etc/default/schema-registry'
        when 'RedHat'
          environment_file = '/etc/sysconfig/schema-registry'
      end

      let(:facts) {
        {
            'osfamily' => osfamily
        }
      }

      let(:params) {
        {
            'config' => {
                'kafkastore.connection.url' => {
                    'value' => 'zookeeper-01:2181,zookeeper-02:2181,zookeeper-03:2181'
                }
            }
        }
      }

      context 'basic setup' do
        expected_heap = '-Xmx256M'

        it {is_expected.to contain_ini_subsetting('schema-registry_SCHEMA_REGISTRY_HEAP_OPTS').with(
            {
                'path' => environment_file,
                'value' => expected_heap
            }
        )}

        it {is_expected.to contain_ini_setting('schema-registry_schema-registry/kafkastore.connection.url').with(
            {
                'path' => '/etc/schema-registry/schema-registry.properties',
                'value' => 'zookeeper-01:2181,zookeeper-02:2181,zookeeper-03:2181'
            }
        )}

        it {is_expected.to contain_package('confluent-schema-registry')}
        it {is_expected.to contain_user('schema-registry')}
        it {is_expected.to contain_service('schema-registry').with(
            {
                'ensure' => 'running',
                'enable' => true
            }
        )}
        it {is_expected.to contain_file('/var/log/schema-registry')}
      end
    end
  end
end