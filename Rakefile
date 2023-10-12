# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

# prepend test:prepare to run generators, and db:prepare to run migrations
RSpec::Core::RakeTask.new(spec: %w[app:spec:prepare])

require "rubocop/katalyst/rake_task"
RuboCop::Katalyst::RakeTask.new

require "rubocop/katalyst/erb_lint_task"
RuboCop::Katalyst::ErbLintTask.new

require "rubocop/katalyst/prettier_task"
RuboCop::Katalyst::PrettierTask.new

task default: %i[lint spec] do
  puts "🎉 build complete! 🎉"
end
