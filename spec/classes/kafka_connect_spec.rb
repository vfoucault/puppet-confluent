require 'spec_helper'

%w(distributed standalone).each do |class_name|
  describe "confluent::kafka::connect::#{class_name}" do
    let(:params) {
      {
          'config' => {
              'bootstrap.servers' => {
                  'value' => 'kafka-01:9093'
              }
          }
      }
    }
    let(:facts) {
      {
          'osfamily' => 'RedHat'
      }
    }
    context 'basic setup' do
      it {is_expected.to contain_file("/var/log/kafka-connect-#{class_name}")}
      it {is_expected.to contain_package('confluent-kafka-2.11')}
      it {is_expected.to contain_ini_setting("kafka-connect-#{class_name}_kafka-connect-#{class_name}/bootstrap.servers").with(
          {
              'path' => "/etc/kafka/connect-#{class_name}.properties",
              'value' => 'kafka-01:9093'
          }
      )}
      it {is_expected.to contain_user("connect-#{class_name}")}
      it {is_expected.to contain_service("kafka-connect-#{class_name}").with(
          {
              'ensure' => 'running',
              'enable' => true
          }
      )}
      it {is_expected.to contain_file("/var/log/kafka-connect-#{class_name}")}
    end

    expected_heap = '-Xmx256M'

    context 'with osfamily => RedHat' do
      let(:facts) {
        {
            'osfamily' => 'RedHat'
        }
      }

      it do
        is_expected.to contain_ini_subsetting("kafka-connect-#{class_name}_KAFKA_HEAP_OPTS").with(
            {
                'path' => "/etc/sysconfig/kafka-connect-#{class_name}",
                'value' => expected_heap
            }
        )
      end
    end

    context 'with osfamily => Debian' do
      let(:facts) {
        {
            'osfamily' => 'Debian'
        }
      }

      it do
        is_expected.to contain_ini_subsetting("kafka-connect-#{class_name}_KAFKA_HEAP_OPTS").with(
            {
                'path' => "/etc/default/kafka-connect-#{class_name}",
                'value' => expected_heap
            }
        )
      end
    end
  end
end
