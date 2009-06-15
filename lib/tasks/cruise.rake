rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

RCov::VerifyTask.new(:verify_rcov){|t|
  t.threshold = 100
  if ENV["CC_BUILD_ARTIFACTS"]
    t.index_html = File.join(ENV["CC_BUILD_ARTIFACTS"],"rcov", "index.html")
  end
}

desc "Task for cruise control"
task :cruise do
  RAILS_ENV = ENV['RAILS_ENV'] = 'test'
  CruiseControl::invoke_rake_task 'db:reset'
  CruiseControl::invoke_rake_task 'cruise_coverage'
  CruiseControl::invoke_rake_task 'verify_rcov'
end

desc "Run specs and rcov"
Spec::Rake::SpecTask.new(:cruise_coverage) do |t|
  if ENV["CC_BUILD_ARTIFACTS"]
    spec_output_file = File.join(ENV["CC_BUILD_ARTIFACTS"], "rcov","index.html")
    FileUtils.mkdir_p(File.dirname(spec_output_file))
  end
  t.spec_opts = ['--option', "#{RAILS_ROOT}/spec/spec.opts", "--format","specdoc"]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  if ENV["CC_BUILD_ARTIFACTS"]
    t.rcov_dir = File.join(ENV["CC_BUILD_ARTIFACTS"], "rcov")
  end
  t.rcov_opts = ['--exclude', 'spec,/usr/local/lib', '--rails', '--text-report']
end

