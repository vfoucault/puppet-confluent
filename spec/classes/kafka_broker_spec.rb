require 'spec_helper'

describe 'confluent::kafka::broker' do


  %w(RedHat Debian).each do |osfamily|
    context "with osfamily => #{osfamily}" do
      environment_file = nil

      case osfamily
        when 'Debian'
          environment_file = '/etc/default/kafka'
        when 'RedHat'
          environment_file = '/etc/sysconfig/kafka'
      end

      let(:facts) {
        {
            'osfamily' => osfamily
        }
      }

      context 'basic setup' do
        let(:params) {
          {
              'broker_id' => '0'
          }
        }
        expected_heap = '-Xmx256M'

        it {is_expected.to contain_ini_subsetting('kafka_KAFKA_HEAP_OPTS').with(
            {
                'path' => environment_file,
                'value' => expected_heap
            }
        )}

        it {is_expected.to contain_ini_setting('kafka_kafka/broker.id').with(
            {
                'path' => '/etc/kafka/server.properties',
                'value' => '0'
            }
        )}
        it {is_expected.to contain_package('confluent-kafka-2.11')}
        it {is_expected.to contain_user('kafka')}
        it {is_expected.to contain_service('kafka').with(
            {
                'ensure' => 'running',
                'enable' => true
            }
        )}
        it {is_expected.to contain_file('/var/log/kafka')}
        it {is_expected.to contain_file('/var/lib/kafka')}
      end

      context 'basic setup with broker_id as integer' do
        let(:params) {
          {
              'broker_id' => 0
          }
        }
        it {is_expected.to contain_ini_setting('kafka_kafka/broker.id').with(
            {
                'path' => '/etc/kafka/server.properties',
                'value' => '0'
            }
        )}
      end
    end
  end
end