# desc "Explaining what the task does"
# task :turbo_modal do
#   # Task goes here
# end

def run_template_path(path)
  system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/#{path}.rb", __dir__)}"
end

def stimulus_installed?
  (Rails.root.join("app/javascript/controllers/index.js")).exist?
end

def switch_on_stimulus
  system "yarn add stimulus@2.0.0"
end

def switch_on_turbo
  Rake::Task["turbo:install"].invoke
end

namespace :turbo_modal do
  desc "Install turbo_modal packages"
  task install: %i[stimulus turbo] do
    run_template_path "turbo_modal"
  end

  task :stimulus do
    switch_on_stimulus unless stimulus_installed?
  end

  task :turbo do
    switch_on_turbo
  end
end
