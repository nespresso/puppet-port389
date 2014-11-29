require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'

PuppetSyntax.exclude_paths = ['spec/fixtures/**/*']

PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_80chars')

PuppetLint::RakeTask.new :lint do |config|
  config.pattern          = 'manifests/**/*.pp'
  config.fail_on_warnings = true
end

task :default => [
  :syntax,
  :lint,
  :spec,
]
