# Class is used to install and configure an Apache Kafka rest proxy using the Confluent installation packages.
#
# @example Installation through class.
#     class{'confluent::kafka::rest':
#       kafka_rest_id => 'kafka-rest-server',
#       config => {
#         'zookeeper.connect' => {
#           'value' => 'zookeeper-01.custenborder.com:2181,zookeeper-02.custenborder.com:2181,zookeeper-03.custenborder.com:2181'
#         },
#       },
#       environment_settings => {
#         'KAFKA_HEAP_OPTS' => {
#           'value' => '-Xmx4000M'
#         }
#       }
#     }
#
# @example Hiera based installation
#     include ::confluent::kafka::broker
#
#     confluent::kafka::rest::kafka_rest_id: 'kafka-rest-server'
#     confluent::kafka::rest::config:
#       zookeeper.connect:
#         value: 'zookeeper-01.example.com:2181,zookeeper-02.example.com:2181,zookeeper-03.example.com:2181'
#       schema.registry.url:
#         value: 'http://schema.registry:8081'
#
# @param kafka_rest_id Rest id
# @param config Hash of configuration values.
# @param environment_settings Hash of environment variables to set for the Kafka scripts.
# @param config_path Location of the server.properties file for the Kafka broker.
# @param environment_file Location of the environment file used to pass environment variables to the Kafka broker.
# @param data_path Location to store the data on disk.
# @param log_path Location to write the log files to.
# @param user User to run the kafka service as.
# @param service_name Name of the kafka service.
# @param manage_service Flag to determine if the service should be managed by puppet.
# @param service_ensure Ensure setting to pass to service resource.
# @param service_enable Enable setting to pass to service resource.
# @param file_limit File limit to set for the Kafka service (SystemD) only.
class confluent::kafka::rest (
  $kafka_rest_id,
  $config               = { },
  $environment_settings = { },
  $config_path          = $::confluent::params::kafka_rest_config_path,
  $environment_file     = $::confluent::params::kafka_environment_path,
  $data_path            = $::confluent::params::kafka_data_path,
  $log_path             = $::confluent::params::kafka_log_path,
  $user                 = $::confluent::params::kafka_user,
  $service_name         = $::confluent::params::kafka_service,
  $manage_service       = $::confluent::params::kafka_manage_service,
  $service_ensure       = $::confluent::params::kafka_service_ensure,
  $service_enable       = $::confluent::params::kafka_service_enable,
  $file_limit           = $::confluent::params::kafka_file_limit,
) inherits confluent::params {
  include ::confluent::kafka


  validate_hash($config)
  validate_hash($environment_settings)
  validate_absolute_path($config_path)
  validate_absolute_path($log_path)
  validate_absolute_path($config_path)

  $application_name = 'kafka-rest'

  $kafka_default_settings = {
    'id' => {
      'value' => $kafka_rest_id
    }
  }

  $java_default_settings = {
    'KAFKA_HEAP_OPTS' => {
      'value' => '-Xmx256M'
    },
    'KAFKA_OPTS'      => {
      'value' => '-Djava.net.preferIPv4Stack=true'
    },
    'GC_LOG_ENABLED'  => {
      'value' => 'true'
    },
    'LOG_DIR'         => {
      'value' => '/var/log/kafka'
    }
  }

  $actual_kafka_settings = merge_hash_with_key_rename($kafka_default_settings, $config, $application_name)
  $actual_java_settings = merge_hash_with_key_rename($java_default_settings, $environment_settings, $application_name)

  ensure_resource('user', $user)
  file { [$log_path, $data_path]:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    recurse => true,
    require => User[$user]
  }

  $ensure_kafka_settings_defaults = {
    'ensure'      => 'present',
    'path'        => $config_path,
    'application' => 'kafka'
  }

  ensure_resources('confluent::java_property', $actual_kafka_settings, $ensure_kafka_settings_defaults)

  $ensure_java_settings_defaults = {
    'path'        => $environment_file,
    'application' => 'kafka'
  }

  ensure_resources('confluent::kafka_environment_variable', $actual_java_settings, $ensure_java_settings_defaults)

  $unit_ini_setting_defaults = {
    'ensure' => 'present'
  }

  $unit_ini_settings = {
    "${service_name}/Unit/Description"        => { 'value' => 'Apache Kafka Rest Proxy by Confluent', },
    "${service_name}/Unit/Wants"              => { 'value' => 'basic.target', },
    "${service_name}/Unit/After"              => { 'value' => 'basic.target network.target', },
    "${service_name}/Service/User"            => { 'value' => $user, },
    "${service_name}/Service/EnvironmentFile" => { 'value' => $environment_file, },
    "${service_name}/Service/ExecStart"       => { 'value' => "/usr/bin/kafka-rest-start ${config_path}", },
    "${service_name}/Service/ExecStop"        => { 'value' => '/usr/bin/kafka-rest-stop', },
    "${service_name}/Service/LimitNOFILE"     => { 'value' => $file_limit, },
    "${service_name}/Service/KillMode"        => { 'value' => 'process', },
    "${service_name}/Service/RestartSec"      => { 'value' => 5, },
    "${service_name}/Service/Type"            => { 'value' => 'simple', },
    "${service_name}/Install/WantedBy"        => { 'value' => 'multi-user.target', },
  }

  ensure_resources('confluent::systemd::unit_ini_setting', $unit_ini_settings, $unit_ini_setting_defaults)

  if($manage_service) {
    service { $service_name:
      ensure => $service_ensure,
      enable => $service_enable
    }
  }
}