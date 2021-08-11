project('stickbot', ['d', 'cpp'], version: '0.0.1')

config_d = configuration_data()
config_d.set_quoted('PACKAGE_VERSION', meson.project_version())
configure_file (
    output: 'stickbot_config.d',
    configuration: config_d
)

subdir ('lib/tms_lib')
subdir ('source')
